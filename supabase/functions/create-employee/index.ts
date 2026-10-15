// Edge Function: create-employee
//
// Crea una cuenta de empleado (o admin) en Supabase Auth y le asigna rol y
// sucursal. Solo puede llamarla un administrador activo.
//
// ¿Por qué una Edge Function? Crear usuarios requiere la clave
// `service_role`, que NUNCA debe ir dentro de la app. Aquí vive en el
// servidor (Supabase la inyecta como variable de entorno).
//
// Llamada desde Flutter:
//   supabase.functions.invoke('create-employee', body: {
//     'email': ..., 'password': ..., 'full_name': ...,
//     'role': 'employee' | 'admin', 'branch_id': <uuid>,
//   });

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Método no permitido." }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "No autorizado." }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // 1. ¿Quién llama? Usamos su propio token.
    const callerClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: userError } = await callerClient.auth
      .getUser();
    if (userError || !user) {
      return json({ error: "Sesión inválida." }, 401);
    }

    // 2. ¿Es administrador?
    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: caller } = await admin
      .from("profiles")
      .select("role, is_active")
      .eq("id", user.id)
      .single();
    if (!caller || caller.role !== "admin" || !caller.is_active) {
      return json(
        { error: "Solo un administrador puede crear empleados." },
        403,
      );
    }

    // 3. Validar datos.
    const body = await req.json();
    const email = String(body.email ?? "").trim().toLowerCase();
    const password = String(body.password ?? "");
    const fullName = String(body.full_name ?? "").trim();
    const role = body.role === "admin" ? "admin" : "employee";
    const branchId = body.branch_id ? String(body.branch_id) : null;

    if (!EMAIL_REGEX.test(email)) {
      return json({ error: "Correo no válido." }, 400);
    }
    if (password.length < 6) {
      return json(
        { error: "La contraseña debe tener al menos 6 caracteres." },
        400,
      );
    }
    if (!fullName) {
      return json({ error: "El nombre es obligatorio." }, 400);
    }
    if (role === "employee" && !branchId) {
      return json({ error: "Un empleado debe tener sucursal." }, 400);
    }

    // 4. Crear la cuenta (el trigger crea el perfil como 'employee').
    const { data: created, error: createError } = await admin.auth.admin
      .createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name: fullName },
      });
    if (createError || !created.user) {
      const alreadyExists = createError?.message
        ?.toLowerCase()
        .includes("already");
      return json(
        {
          error: alreadyExists
            ? "Ya existe un usuario con ese correo."
            : createError?.message ?? "No se pudo crear el usuario.",
        },
        alreadyExists ? 409 : 400,
      );
    }

    // 5. Asignar rol y sucursal.
    const { error: profileError } = await admin
      .from("profiles")
      .update({ full_name: fullName, role, branch_id: branchId })
      .eq("id", created.user.id);
    if (profileError) {
      // Deshacemos para no dejar cuentas a medias.
      await admin.auth.admin.deleteUser(created.user.id);
      return json({ error: profileError.message }, 400);
    }

    return json({ id: created.user.id }, 201);
  } catch (error) {
    return json({ error: `Error inesperado: ${error}` }, 500);
  }
});
