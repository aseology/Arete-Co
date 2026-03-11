import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const TO_EMAIL = "ask@aretebuilds.com";
const FROM_EMAIL = "Arete & Co. <forms@aretebuilds.com>";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { formType, ...fields } = body;

    let subject = "";
    let html = "";

    if (formType === "contact") {
      const { name, email, project, message } = fields;
      subject = `New Contact — ${name}`;
      html = `<div style="font-family:monospace;max-width:600px;margin:0 auto;background:#111112;color:#F4F1EA;padding:2rem;border-top:3px solid #7FFF00;"><div style="font-size:.7rem;letter-spacing:.25em;text-transform:uppercase;color:#7FFF00;margin-bottom:1.5rem;">ARETE & CO. — NEW CONTACT</div><table style="width:100%;border-collapse:collapse;"><tr><td style="padding:.5rem 0;color:#888580;font-size:.75rem;width:120px;">Name</td><td style="padding:.5rem 0;font-size:.8rem;">${name}</td></tr><tr><td style="padding:.5rem 0;color:#888580;font-size:.75rem;">Email</td><td style="padding:.5rem 0;font-size:.8rem;"><a href="mailto:${email}" style="color:#7FFF00;">${email}</a></td></tr><tr><td style="padding:.5rem 0;color:#888580;font-size:.75rem;">Project</td><td style="padding:.5rem 0;font-size:.8rem;">${project || "—"}</td></tr></table><div style="margin-top:1.5rem;padding:1rem;background:#1A1A1B;border-left:2px solid #7FFF00;"><div style="color:#888580;font-size:.65rem;letter-spacing:.1em;text-transform:uppercase;margin-bottom:.5rem;">Message</div><div style="font-size:.8rem;line-height:1.7;">${message.replace(/\n/g, "<br>")}</div></div><div style="margin-top:1.5rem;font-size:.6rem;color:#888580;">Submitted via aretebuilds.com/contact</div></div>`;
    } else if (formType === "brief") {
      const { team, mission, audience, challenge, successMetrics, financialGoals, resources, timeline } = fields;
      subject = `New Foundation Brief — ${new Date().toLocaleDateString("en-US", { month: "long", day: "numeric" })}`;
      const rows = [["Team / Stakeholders", team],["Mission & Purpose", mission],["Audience", audience],["Core Challenge", challenge],["Success Metrics", successMetrics],["Financial Goals", financialGoals],["Resources & Gaps", resources],["Timeline", timeline]];
      html = `<div style="font-family:monospace;max-width:600px;margin:0 auto;background:#111112;color:#F4F1EA;padding:2rem;border-top:3px solid #7FFF00;"><div style="font-size:.7rem;letter-spacing:.25em;text-transform:uppercase;color:#7FFF00;margin-bottom:1.5rem;">ARETE & CO. — FOUNDATION BRIEF</div>${rows.map(([l,v])=>v?`<div style="margin-bottom:1.25rem;padding:1rem;background:#1A1A1B;border-left:2px solid #2a2a2b;"><div style="color:#888580;font-size:.6rem;letter-spacing:.12em;text-transform:uppercase;margin-bottom:.4rem;">${l}</div><div style="font-size:.8rem;line-height:1.7;">${String(v).replace(/\n/g,"<br>")}</div></div>`:"").join("")}<div style="margin-top:1.5rem;font-size:.6rem;color:#888580;">Submitted via aretebuilds.com/brief</div></div>`;
    } else {
      return new Response(JSON.stringify({ error: "Unknown formType" }), { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { "Authorization": `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({ from: FROM_EMAIL, to: TO_EMAIL, subject, html }),
    });

    const data = await res.json();
    if (!res.ok) return new Response(JSON.stringify({ error: data }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    return new Response(JSON.stringify({ success: true, id: data.id }), { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } });

  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
