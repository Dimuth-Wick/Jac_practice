"""Public portfolio and administrator interface, authored in Jac."""

import from "@jac/runtime" { jacIsLoggedIn, jacLogin, jacLogout }
sv import from portfolio_api {
    ActionResult,
    AdminData,
    PortfolioData,
    PortfolioProfile,
    PortfolioProject,
    create_project,
    delete_contact_message,
    delete_project,
    get_admin_data,
    get_portfolio,
    save_profile,
    submit_contact,
    update_project,
}

glob PAGE_STYLE: str = """
:root {
  color-scheme: light;
  --ink: #182329;
  --muted: #66777b;
  --paper: #f6f7f2;
  --card: #ffffff;
  --line: #dce4df;
  --accent: #d3583b;
  --accent-dark: #9e3c27;
  --green: #c8e4d1;
  --blue: #dbe9f0;
  --radius: 22px;
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  font-synthesis: none;
  text-rendering: optimizeLegibility;
}
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body { margin: 0; background: var(--paper); color: var(--ink); }
a { color: inherit; }
a:focus-visible, button:focus-visible, input:focus-visible, textarea:focus-visible {
  outline: 3px solid #167a77;
  outline-offset: 4px;
}
button, input, textarea { font: inherit; }
button, a { -webkit-tap-highlight-color: transparent; }
.skip-link {
  position: absolute; left: 1rem; top: -5rem; z-index: 20;
  padding: .8rem 1rem; background: var(--ink); color: white; border-radius: 8px;
}
.skip-link:focus { top: 1rem; }
.site-shell { max-width: 1240px; padding: 0 32px; margin: 0 auto; }
.topbar {
  min-height: 82px; display: flex; align-items: center; justify-content: space-between;
  gap: 24px; border-bottom: 1px solid var(--line);
}
.brand { display: inline-flex; align-items: center; gap: 11px; text-decoration: none; font-weight: 800; letter-spacing: -.04em; }
.brand-mark {
  width: 38px; height: 38px; display: grid; place-items: center; border-radius: 13px;
  color: white; background: var(--ink); font-size: .88rem; letter-spacing: -.02em;
}
.nav-links { display: flex; flex-wrap: wrap; gap: 7px; align-items: center; }
.nav-links a {
  padding: 10px 13px; color: var(--muted); border-radius: 999px; text-decoration: none;
  font-size: .88rem; transition: color .2s ease, background .2s ease;
}
.nav-links a:hover { color: var(--ink); background: #e9eee9; }
.nav-links .admin-link { color: var(--accent-dark); }
.hero {
  min-height: 620px; display: grid; grid-template-columns: minmax(0, 1.2fr) minmax(270px, .8fr);
  align-items: center; gap: clamp(34px, 7vw, 100px); padding: 84px 0 92px;
}
.hero-copy, .hero-art, .reveal { animation: rise-in .75s cubic-bezier(.2,.7,.2,1) both; }
.hero-art { animation-delay: .12s; }
.eyebrow {
  display: inline-flex; align-items: center; gap: 9px; color: var(--accent-dark);
  font-size: .76rem; font-weight: 800; letter-spacing: .14em; text-transform: uppercase;
}
.eyebrow-dot { width: 8px; height: 8px; background: #5b986c; border-radius: 50%; box-shadow: 0 0 0 5px #dceee0; }
.hero h1 {
  max-width: 760px; margin: 22px 0; font-size: clamp(3.2rem, 7.5vw, 6.9rem);
  line-height: .96; letter-spacing: -.075em; font-weight: 780;
}
.hero h1 em { color: var(--accent); font-style: normal; }
.hero-lede { max-width: 600px; color: var(--muted); font-size: clamp(1.08rem, 2vw, 1.28rem); line-height: 1.75; }
.hero-actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 32px; }
.button {
  min-height: 48px; display: inline-flex; justify-content: center; align-items: center; gap: 9px;
  padding: 0 19px; border: 1px solid var(--ink); border-radius: 999px; text-decoration: none;
  font-weight: 750; transition: transform .2s ease, background .2s ease, color .2s ease;
}
.button:hover { transform: translateY(-2px); }
.button-primary { background: var(--ink); color: white; }
.button-primary:hover { background: #334347; }
.button-secondary { background: transparent; }
.button-secondary:hover { background: #e9eee9; }
.hero-art {
  position: relative; min-height: 395px; display: grid; place-items: center;
  border: 1px solid #c9d8d0; border-radius: 46% 54% 56% 44% / 50% 43% 57% 50%;
  background: radial-gradient(circle at 65% 24%, #fff9ed 0 8%, transparent 8.5%),
              radial-gradient(circle at 35% 70%, #f1b6a3 0 9%, transparent 9.5%),
              linear-gradient(145deg, #d5e9da, #b8d4cd 58%, #d9e8e8);
  overflow: hidden; isolation: isolate;
}
.hero-art:before, .hero-art:after {
  content: ""; position: absolute; z-index: -1; border: 1px solid #5e7e78;
  border-radius: 50%; transform: rotate(-28deg);
}
.hero-art:before { width: 76%; height: 52%; }
.hero-art:after { width: 102%; height: 73%; transform: rotate(42deg); opacity: .55; }
.art-orbit {
  width: 155px; height: 190px; display: grid; place-items: center; border-radius: 48% 48% 40% 40%;
  color: white; background: linear-gradient(150deg, #273c3d, #55736c);
  box-shadow: 0 28px 55px #29423b55; font-size: 3.8rem; font-weight: 800; letter-spacing: -.09em;
  transform: rotate(-6deg);
}
.art-note {
  position: absolute; right: 5%; bottom: 11%; max-width: 180px; padding: 15px 17px;
  background: #fffdf5; border: 1px solid #e5e2d7; border-radius: 15px;
  box-shadow: 0 12px 24px #283c3217; font-size: .86rem; line-height: 1.5;
}
.sample-banner {
  margin: 0 0 28px; padding: 14px 18px; border: 1px solid #e5c8a0; border-radius: 14px;
  background: #fff4e3; color: #604522; font-size: .9rem; line-height: 1.55;
}
.section { padding: 100px 0; border-top: 1px solid var(--line); scroll-margin-top: 25px; }
.section-head {
  display: flex; align-items: end; justify-content: space-between; gap: 28px; margin-bottom: 42px;
}
.section-kicker { color: var(--accent-dark); font-size: .75rem; font-weight: 800; letter-spacing: .15em; text-transform: uppercase; }
.section h2 { margin: 11px 0 0; font-size: clamp(2.3rem, 4.6vw, 4.2rem); letter-spacing: -.065em; line-height: 1.05; }
.section-intro { max-width: 450px; margin: 0; color: var(--muted); line-height: 1.75; }
.about-grid { display: grid; grid-template-columns: minmax(0, .82fr) minmax(0, 1.18fr); gap: 48px; align-items: start; }
.about-quote {
  padding: clamp(25px, 4vw, 44px); border-radius: var(--radius);
  background: var(--green); font-size: clamp(1.35rem, 2.7vw, 2rem);
  line-height: 1.45; letter-spacing: -.045em;
}
.about-copy { color: var(--muted); font-size: 1.02rem; line-height: 1.85; }
.meta-row { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 24px; }
.meta-chip, .tag {
  display: inline-flex; align-items: center; padding: 8px 12px; border: 1px solid var(--line);
  border-radius: 999px; color: var(--muted); background: #ffffffa8; font-size: .8rem;
}
.resume-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 48px; }
.resume-list { display: grid; gap: 12px; margin-top: 24px; }
.resume-item { padding: 22px 0; border-top: 1px solid var(--line); }
.resume-item h3 { margin: 0 0 5px; font-size: 1.05rem; letter-spacing: -.025em; }
.resume-item p { margin: 6px 0 0; color: var(--muted); line-height: 1.65; }
.resume-period { color: var(--accent-dark) !important; font-size: .82rem; font-weight: 750; }
.skills-cloud { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 24px; }
.skill-pill { padding: 12px 15px; border: 1px solid #c7d5ce; border-radius: 12px; background: #edf4ef; font-size: .9rem; }
.project-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 18px; }
.project-card {
  min-height: 320px; display: flex; flex-direction: column; padding: 25px;
  border: 1px solid var(--line); border-radius: var(--radius); background: var(--card);
  transition: transform .25s ease, box-shadow .25s ease;
}
.project-card:hover { transform: translateY(-5px); box-shadow: 0 18px 35px #21352d12; }
.project-art { min-height: 112px; display: grid; place-items: center; margin-bottom: 22px; border-radius: 15px; overflow: hidden; }
.project-art-a { background: linear-gradient(140deg, #f1c9b8, #f8e3c9); }
.project-art-b { background: linear-gradient(140deg, #d2e7dc, #bad7cc); }
.project-art-c { background: linear-gradient(140deg, #d5dfef, #c9d7ed); }
.project-glyph { color: #344c48; font-size: 2.5rem; font-weight: 800; letter-spacing: -.1em; }
.project-topline { display: flex; justify-content: space-between; gap: 12px; color: var(--muted); font-size: .78rem; }
.project-card h3 { margin: 12px 0 8px; font-size: 1.35rem; letter-spacing: -.04em; }
.project-card p { margin: 0; color: var(--muted); line-height: 1.65; }
.tag-list { display: flex; flex-wrap: wrap; gap: 7px; margin-top: 18px; }
.project-footer { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-top: auto; padding-top: 19px; }
.project-link { color: var(--accent-dark); font-size: .86rem; font-weight: 750; text-decoration-thickness: 1px; text-underline-offset: 4px; }
.contact-panel {
  display: grid; grid-template-columns: .8fr 1.2fr; gap: 40px; padding: clamp(25px, 5vw, 58px);
  border-radius: 30px; background: var(--ink); color: white;
}
.contact-panel h2 { margin: 14px 0; font-size: clamp(2.2rem, 4vw, 3.7rem); letter-spacing: -.06em; line-height: 1.05; }
.contact-panel p { color: #bdc9c7; line-height: 1.75; }
.contact-email { display: inline-block; margin-top: 15px; color: #f3b79f; font-weight: 700; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.field { display: grid; gap: 7px; }
.field-wide { grid-column: 1 / -1; }
.field label { color: #e0e8e4; font-size: .84rem; font-weight: 700; }
.field input, .field textarea {
  width: 100%; min-height: 47px; padding: 12px 14px; border: 1px solid #536365;
  border-radius: 11px; background: #233438; color: white; resize: vertical;
}
.field textarea { min-height: 125px; }
.field input::placeholder, .field textarea::placeholder { color: #a6b5b1; }
.form-note { min-height: 1.5em; grid-column: 1 / -1; color: #f3cbbd; }
.form-note-success { color: #a7dfbd; }
.site-footer { display: flex; justify-content: space-between; flex-wrap: wrap; gap: 18px; padding: 28px 0 38px; color: var(--muted); font-size: .85rem; }
.social-list { display: flex; flex-wrap: wrap; gap: 14px; }
.social-link { color: var(--ink); font-weight: 700; text-underline-offset: 4px; }
.social-placeholder { color: var(--muted); font-size: .84rem; }
.admin-area { padding: 48px 0 80px; border-top: 1px solid var(--line); scroll-margin-top: 20px; }
.admin-card { padding: clamp(22px, 4vw, 38px); border: 1px solid var(--line); border-radius: var(--radius); background: white; }
.admin-header { display: flex; justify-content: space-between; align-items: start; gap: 20px; }
.admin-header h2 { margin: 7px 0; font-size: clamp(1.8rem, 4vw, 2.8rem); letter-spacing: -.055em; }
.admin-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 26px; }
.admin-form { display: grid; gap: 14px; }
.admin-form .field label { color: var(--ink); }
.admin-form input, .admin-form textarea { border-color: var(--line); background: #fbfcf9; color: var(--ink); }
.admin-form input::placeholder, .admin-form textarea::placeholder { color: #849296; }
.admin-form textarea { min-height: 100px; }
.admin-actions { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 16px; }
.admin-button { min-height: 42px; padding: 0 15px; border: 1px solid var(--ink); border-radius: 999px; background: var(--ink); color: white; font-weight: 750; cursor: pointer; }
.admin-button-secondary { background: white; color: var(--ink); }
.admin-button-danger { border-color: #a54135; background: #a54135; }
.admin-button:disabled { opacity: .55; cursor: wait; }
.admin-list { display: grid; gap: 10px; margin-top: 18px; }
.admin-row { display: flex; align-items: start; justify-content: space-between; gap: 15px; padding: 15px; border: 1px solid var(--line); border-radius: 13px; }
.admin-row p { margin: 5px 0 0; color: var(--muted); font-size: .9rem; line-height: 1.55; overflow-wrap: anywhere; }
.admin-message { white-space: pre-wrap; }
.admin-notice { min-height: 1.4em; color: var(--accent-dark); line-height: 1.5; }
.empty-state { padding: 25px; border: 1px dashed #bdcbc3; border-radius: 14px; color: var(--muted); }
.muted { color: var(--muted); }
@keyframes rise-in { from { opacity: 0; transform: translateY(18px); } to { opacity: 1; transform: translateY(0); } }
@media (max-width: 900px) {
  .hero { min-height: auto; grid-template-columns: 1fr .72fr; gap: 28px; padding: 72px 0; }
  .hero-art { min-height: 310px; }
  .project-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .contact-panel { grid-template-columns: 1fr; gap: 18px; }
}
@media (max-width: 650px) {
  .site-shell { padding: 0 19px; }
  .topbar { min-height: 72px; flex-wrap: wrap; justify-content: center; gap: 8px; padding: 12px 0; }
  .brand { margin-right: auto; }
  .nav-links { justify-content: flex-end; gap: 0; }
  .nav-links a { padding: 8px; font-size: .78rem; }
  .hero { grid-template-columns: 1fr; padding: 58px 0 68px; }
  .hero h1 { font-size: clamp(3.2rem, 15vw, 5rem); }
  .hero-art { min-height: 260px; max-width: 430px; width: 100%; margin: 0 auto; }
  .art-orbit { width: 120px; height: 145px; font-size: 3rem; }
  .section { padding: 70px 0; }
  .section-head { display: block; margin-bottom: 30px; }
  .section-intro { margin-top: 16px; }
  .about-grid, .resume-grid, .admin-grid { grid-template-columns: 1fr; gap: 24px; }
  .project-grid { grid-template-columns: 1fr; }
  .project-card { min-height: 300px; }
  .contact-panel { padding: 24px 18px; border-radius: 22px; }
  .form-grid { grid-template-columns: 1fr; }
  .field-wide { grid-column: auto; }
  .admin-header { display: block; }
  .admin-row { flex-direction: column; }
}
@media (prefers-reduced-motion: reduce) {
  *, *:before, *:after { scroll-behavior: auto !important; animation-duration: .01ms !important; animation-iteration-count: 1 !important; transition-duration: .01ms !important; }
}
""";

def _join_text(parts: list[str], separator: str) -> str {
    result = "";
    for (index, part) in enumerate(parts) {
        if index > 0 {
            result += separator;
        }
        result += part;
    }
    return result;
}

def _rows_to_text(rows: list[dict[str, str]], fields: list[str]) -> str {
    lines: list[str] = [];
    for row in rows {
        lines.append(_join_text([row.get(field, "") for field in fields], " | "));
    }
    return _join_text(lines, "\n");
}

def _rows_are_valid(text: str, field_count: int) -> bool {
    for line in text.split("\n") {
        if line.strip() and len(line.split("|")) != field_count {
            return False;
        }
    }
    return True;
}

def _text_to_rows(text: str, fields: list[str]) -> list[dict[str, str]] {
    rows: list[dict[str, str]] = [];
    for line in text.split("\n") {
        if not line.strip() {
            continue;
        }
        values = [value.strip() for value in line.split("|")];
        if len(values) == len(fields) {
            row: dict[str, str] = {};
            for (index, field) in enumerate(fields) {
                row[field] = values[index];
            }
            rows.append(row);
        }
    }
    return rows;
}

def:pub app -> JsxElement {
    has site: PortfolioData | None = None,
        admin_data: AdminData | None = None,
        is_loading: bool = True,
        is_submitting: bool = False,
        is_admin: bool = False,
        show_admin: bool = False,
        admin_busy: bool = False,
        contact_name: str = "",
        contact_email: str = "",
        contact_subject: str = "",
        contact_message: str = "",
        contact_notice: str = "",
        contact_success: bool = False,
        admin_username: str = "admin",
        admin_password: str = "",
        admin_notice: str = "",
        full_name: str = "",
        role: str = "",
        headline: str = "",
        location: str = "",
        profile_email: str = "",
        bio: str = "",
        sample_content: bool = True,
        skills_text: str = "",
        experience_text: str = "",
        education_text: str = "",
        socials_text: str = "",
        project_id: str = "",
        project_title: str = "",
        project_category: str = "",
        project_summary: str = "",
        project_year: str = "",
        project_tags: str = "",
        project_link: str = "";

    async def load_site -> None {
        is_loading = True;
        try {
            site = await get_portfolio();
        } except Exception as error {
            admin_notice = "The portfolio could not be loaded: " + str(error);
        }
        is_loading = False;
    }

    async def load_admin -> None {
        try {
            data: AdminData = await get_admin_data();
            admin_data = data;
            is_admin = True;
            full_name = data.profile.full_name;
            role = data.profile.role;
            headline = data.profile.headline;
            location = data.profile.location;
            profile_email = data.profile.email;
            bio = data.profile.bio;
            sample_content = data.profile.sample_content;
            skills_text = _join_text(data.profile.skills, ", ");
            experience_text = _rows_to_text(
                data.profile.experience,
                ["role", "organization", "period", "summary"]
            );
            education_text = _rows_to_text(
                data.profile.education,
                ["qualification", "institution", "period"]
            );
            socials_text = _rows_to_text(data.profile.socials, ["label", "url"]);
            admin_notice = "Administrator access verified.";
        } except Exception as error {
            is_admin = False;
            admin_data = None;
            admin_notice = "Administrator access was not verified: " + str(error);
            jacLogout();
            return;
        }
    }

    async def refresh_site -> None {
        site = await get_portfolio();
    }

    async def sign_in(e: FormEvent) -> None {
        e.preventDefault();
        admin_busy = True;
        admin_notice = "";
        login_ok: bool = False;
        try {
            login_ok = await jacLogin(admin_username, admin_password);
        } except Exception as error {
            admin_notice = "Sign in failed: " + str(error);
            admin_busy = False;
            return;
        }
        if not login_ok {
            admin_notice = "The administrator username or password was not accepted.";
            admin_busy = False;
            return;
        }
        await load_admin();
        admin_password = "";
        admin_busy = False;
    }

    async def save_profile_form(e: FormEvent) -> None {
        e.preventDefault();
        if (
            not _rows_are_valid(socials_text, 2)
            or not _rows_are_valid(experience_text, 4)
            or not _rows_are_valid(education_text, 3)
        ) {
            admin_notice = "Use one entry per line: resume Role | Organization | Dates | Summary; education Qualification | Institution | Dates; social Platform | HTTPS URL.";
            return;
        }
        admin_busy = True;
        try {
            result: ActionResult = await save_profile(
                full_name=full_name,
                role=role,
                headline=headline,
                location=location,
                email=profile_email,
                bio=bio,
                sample_content=sample_content,
                skills=[skill.strip() for skill in skills_text.split(",") if skill.strip()],
                experience=_text_to_rows(
                experience_text,
                ["role", "organization", "period", "summary"]
                ),
                education=_text_to_rows(
                education_text,
                ["qualification", "institution", "period"]
                ),
                socials=_text_to_rows(socials_text, ["label", "url"])
            );
            admin_notice = result.message;
            if result.ok {
                await refresh_site();
                await load_admin();
            }
        } except Exception as error {
            admin_notice = "Portfolio content could not be saved: " + str(error);
        }
        admin_busy = False;
    }

    def clear_project_form -> None {
        project_id = "";
        project_title = "";
        project_category = "";
        project_summary = "";
        project_year = "";
        project_tags = "";
        project_link = "";
    }

    def edit_project(project: PortfolioProject) -> None {
        project_id = jid(project);
        project_title = project.title;
        project_category = project.category;
        project_summary = project.summary;
        project_year = project.year;
        project_tags = _join_text(project.tags, ", ");
        project_link = project.link;
        admin_notice = "Editing " + project.title + ".";
    }

    async def save_project_form(e: FormEvent) -> None {
        e.preventDefault();
        project_tags_list = [tag.strip() for tag in project_tags.split(",") if tag.strip()];
        admin_busy = True;
        try {
            result: ActionResult = (
                await update_project(
                    project_id=project_id,
                    title=project_title,
                    category=project_category,
                    summary=project_summary,
                    year=project_year,
                    tags=project_tags_list,
                    link=project_link
                )
                if project_id
                else await create_project(
                    title=project_title,
                    category=project_category,
                    summary=project_summary,
                    year=project_year,
                    tags=project_tags_list,
                    link=project_link
                )
            );
            admin_notice = result.message;
            if result.ok {
                clear_project_form();
                await refresh_site();
                await load_admin();
            }
        } except Exception as error {
            admin_notice = "Project could not be saved: " + str(error);
        }
        admin_busy = False;
    }

    async def remove_project(id: str) -> None {
        admin_busy = True;
        try {
            result: ActionResult = await delete_project(id);
            admin_notice = result.message;
            if result.ok {
                if project_id == id {
                    clear_project_form();
                }
                await refresh_site();
                await load_admin();
            }
        } except Exception as error {
            admin_notice = "Project could not be deleted: " + str(error);
        }
        admin_busy = False;
    }

    async def remove_message(id: str) -> None {
        admin_busy = True;
        try {
            result: ActionResult = await delete_contact_message(id);
            admin_notice = result.message;
            if result.ok {
                await load_admin();
            }
        } except Exception as error {
            admin_notice = "Message could not be deleted: " + str(error);
        }
        admin_busy = False;
    }

    async def sign_out -> None {
        jacLogout();
        is_admin = False;
        admin_data = None;
        admin_notice = "Signed out.";
    }

    async def send_message(e: FormEvent) -> None {
        e.preventDefault();
        is_submitting = True;
        contact_notice = "";
        try {
            result: ActionResult = await submit_contact(
                contact_name,
                contact_email,
                contact_subject,
                contact_message
            );
            contact_notice = result.message;
            contact_success = result.ok;
            if result.ok {
                contact_name = "";
                contact_email = "";
                contact_subject = "";
                contact_message = "";
            }
        } except Exception as error {
            contact_success = False;
            contact_notice = "Your message could not be saved: " + str(error);
        }
        is_submitting = False;
    }

    async can with entry {
        await load_site();
        if jacIsLoggedIn() {
            show_admin = True;
            await load_admin();
        }
    }

    profile: PortfolioProfile | None = site.profile if site is not None else None;
    projects: list[PortfolioProject] = site.projects if site is not None else [];

    return
        <div>
            <style>{PAGE_STYLE}</style>
            <a className="skip-link" href="#main-content">Skip to content</a>
            <div className="site-shell">
                <header className="topbar">
                    <a className="brand" href="#top" aria-label="Back to top">
                        <span className="brand-mark" aria-hidden={True}>AM</span>
                        <span>Portfolio / CV</span>
                    </a>
                    <nav className="nav-links" aria-label="Main navigation">
                        <a href="#about">About</a>
                        <a href="#resume">Resume</a>
                        <a href="#projects">Projects</a>
                        <a href="#contact">Contact</a>
                        <a
                            className="admin-link"
                            href="#admin"
                            onClick={lambda (e: MouseEvent) { show_admin = True; }}
                        >Admin</a>
                    </nav>
                </header>

                <main id="main-content">
                    {if is_loading {
                        <section className="hero" aria-busy={True} aria-label="Loading portfolio">
                            <p className="muted">Loading portfolio content...</p>
                        </section>
                    } elif site is None or profile is None {
                        <section className="hero" role="alert">
                            <p className="muted">Portfolio content could not be loaded. Reload the page to try again.</p>
                        </section>
                    } else {
                        <div id="top">
                            {if profile.sample_content {
                                <div className="sample-banner" role="status">
                                    Sample portfolio content is shown. Replace the profile, resume, project, and social details in Admin before sharing this site.
                                </div>
                            }}
                            <section className="hero">
                                <div className="hero-copy">
                                    <div className="eyebrow"><span className="eyebrow-dot" aria-hidden={True}></span>{profile.role}</div>
                                    <h1>Making good ideas <em>feel</em> at home.</h1>
                                    <p className="hero-lede">{profile.headline}</p>
                                    <div className="hero-actions">
                                        <a className="button button-primary" href="#projects">Explore selected work <span aria-hidden={True}>-&gt;</span></a>
                                        <a className="button button-secondary" href="#contact">Start a conversation</a>
                                    </div>
                                </div>
                                <div className="hero-art" aria-label="Abstract portfolio illustration" role="img">
                                    <div className="art-orbit" aria-hidden={True}>AM</div>
                                    <div className="art-note">Curiosity first.<br />Care in every detail.</div>
                                </div>
                            </section>

                            <section className="section" id="about" aria-labelledby="about-title">
                                <div className="section-head">
                                    <div><div className="section-kicker">01 / A little about me</div><h2 id="about-title">Work with intention.</h2></div>
                                    <p className="section-intro">A short introduction to the person behind the projects.</p>
                                </div>
                                <div className="about-grid">
                                    <div className="about-quote">“Good design makes the complicated feel clear, and the everyday feel a little more human.”</div>
                                    <div>
                                        <p className="about-copy">{profile.bio}</p>
                                        <div className="meta-row">
                                            <span className="meta-chip">{profile.full_name}</span>
                                            <span className="meta-chip">{profile.location}</span>
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <section className="section" id="resume" aria-labelledby="resume-title">
                                <div className="section-head">
                                    <div><div className="section-kicker">02 / Resume</div><h2 id="resume-title">The experience so far.</h2></div>
                                    <p className="section-intro">Experience, education, and the skills I bring to a team.</p>
                                </div>
                                <div className="resume-grid">
                                    <div>
                                        <h3>Experience</h3>
                                        <div className="resume-list">
                                            {for (index, item) in enumerate(profile.experience) {
                                                <article className="resume-item" key={index}>
                                                    <h3>{item["role"]}</h3>
                                                    <p>{item["organization"]}</p>
                                                    <p className="resume-period">{item["period"]}</p>
                                                    <p>{item["summary"]}</p>
                                                </article>
                                            }}
                                        </div>
                                        <h3>Education</h3>
                                        <div className="resume-list">
                                            {for (index, item) in enumerate(profile.education) {
                                                <article className="resume-item" key={index}>
                                                    <h3>{item["qualification"]}</h3>
                                                    <p>{item["institution"]}</p>
                                                    <p className="resume-period">{item["period"]}</p>
                                                </article>
                                            }}
                                        </div>
                                    </div>
                                    <div>
                                        <h3>Skills &amp; strengths</h3>
                                        <div className="skills-cloud">
                                            {for (index, skill) in enumerate(profile.skills) {
                                                <span className="skill-pill" key={index}>{skill}</span>
                                            }}
                                        </div>
                                        <div className="resume-item">
                                            <p className="muted">For a complete CV, contact me or ask the administrator to add a downloadable document when one is available.</p>
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <section className="section" id="projects" aria-labelledby="projects-title">
                                <div className="section-head">
                                    <div><div className="section-kicker">03 / Selected projects</div><h2 id="projects-title">A few things I’ve made.</h2></div>
                                    <p className="section-intro">A collection of work, experiments, and ideas. Sample entries are explicitly marked.</p>
                                </div>
                                {if len(projects) == 0 {
                                    <p className="empty-state">Projects will appear here when they are published.</p>
                                } else {
                                    <div className="project-grid">
                                        {for (index, project) in enumerate(projects) {
                                            <article className="project-card" key={jid(project)}>
                                                <div className={"project-art project-art-" + ["a", "b", "c"][index % 3]} aria-hidden={True}>
                                                    <span className="project-glyph">{project.title[:1]}</span>
                                                </div>
                                                <div className="project-topline"><span>{project.category}</span><span>{project.year}</span></div>
                                                <h3>{project.title}</h3>
                                                <p>{project.summary}</p>
                                                <div className="tag-list">
                                                    {for (tag_index, tag) in enumerate(project.tags) {
                                                        <span className="tag" key={tag_index}>{tag}</span>
                                                    }}
                                                </div>
                                                <div className="project-footer">
                                                    {if project.link {
                                                        <a className="project-link" href={project.link} target="_blank" rel="noreferrer">View project <span aria-hidden={True}>-&gt;</span></a>
                                                    } else {
                                                        <span className="social-placeholder">Add a project link in Admin</span>
                                                    }}
                                                </div>
                                            </article>
                                        }}
                                    </div>
                                }}
                            </section>

                            <section className="section" id="contact" aria-labelledby="contact-title">
                                <div className="contact-panel">
                                    <div>
                                        <div className="section-kicker">04 / Get in touch</div>
                                        <h2 id="contact-title">Have a good one in mind?</h2>
                                        <p>Use the form to leave a note. In this local starter, messages are saved for review and are not emailed.</p>
                                        <a className="contact-email" href={"mailto:" + profile.email}>{profile.email}</a>
                                        <div className="social-list" aria-label="Social media links">
                                            {for (index, social) in enumerate(profile.socials) {
                                                if social["url"] {
                                                    <a className="social-link" key={index} href={social["url"]} target="_blank" rel="noreferrer">{social["label"]}</a>
                                                } else {
                                                    <span className="social-placeholder" key={index}>{social["label"]}: add your URL in Admin</span>
                                                }
                                            }}
                                        </div>
                                    </div>
                                    <form className="form-grid" onSubmit={send_message}>
                                        <div className="field">
                                            <label htmlFor="contact-name">Your name</label>
                                            <input id="contact-name" name="name" autoComplete="name" minLength={2} maxLength={100} required value={contact_name} onChange={lambda (e: ChangeEvent) { contact_name = e.target.value; }} />
                                        </div>
                                        <div className="field">
                                            <label htmlFor="contact-email">Email address</label>
                                            <input id="contact-email" name="email" type="email" autoComplete="email" maxLength={254} required value={contact_email} onChange={lambda (e: ChangeEvent) { contact_email = e.target.value; }} />
                                        </div>
                                        <div className="field field-wide">
                                            <label htmlFor="contact-subject">Subject</label>
                                            <input id="contact-subject" name="subject" minLength={2} maxLength={120} required value={contact_subject} onChange={lambda (e: ChangeEvent) { contact_subject = e.target.value; }} />
                                        </div>
                                        <div className="field field-wide">
                                            <label htmlFor="contact-message">Message</label>
                                            <textarea id="contact-message" name="message" minLength={10} maxLength={5000} rows={5} required value={contact_message} onChange={lambda (e: ChangeEvent) { contact_message = e.target.value; }}></textarea>
                                        </div>
                                        <p className={"form-note" + (" form-note-success" if contact_success else "")} aria-live="polite">{contact_notice}</p>
                                        <button className="button button-secondary" type="submit" disabled={is_submitting}>
                                            {"Saving..." if is_submitting else "Send message"}
                                        </button>
                                    </form>
                                </div>
                            </section>
                        </div>
                    }}
                </main>

                <footer className="site-footer">
                    <span>Made with care. Built in Jac.</span>
                    <a href="#top">Back to top</a>
                </footer>

                {if show_admin {
                    <section className="admin-area" id="admin" aria-labelledby="admin-title">
                        <div className="admin-card">
                            <div className="admin-header">
                                <div>
                                    <div className="section-kicker">Private workspace</div>
                                    <h2 id="admin-title">Portfolio admin</h2>
                                    <p className="muted">Only the configured Jac Scale administrator can read or change this content.</p>
                                </div>
                                <button className="admin-button admin-button-secondary" type="button" onClick={lambda (e: MouseEvent) { show_admin = False; }}>Close</button>
                            </div>
                            {if not is_admin {
                                <form className="admin-form" onSubmit={sign_in}>
                                    <div className="field">
                                        <label htmlFor="admin-username">Administrator username</label>
                                        <input id="admin-username" name="username" autoComplete="username" required value={admin_username} onChange={lambda (e: ChangeEvent) { admin_username = e.target.value; }} />
                                    </div>
                                    <div className="field">
                                        <label htmlFor="admin-password">Administrator password</label>
                                        <input id="admin-password" name="password" type="password" autoComplete="current-password" required value={admin_password} onChange={lambda (e: ChangeEvent) { admin_password = e.target.value; }} />
                                    </div>
                                    <div className="admin-actions"><button className="admin-button" type="submit" disabled={admin_busy}>{"Verifying..." if admin_busy else "Sign in securely"}</button></div>
                                    <p className="admin-notice" role="status" aria-live="polite">{admin_notice}</p>
                                </form>
                            } else {
                                <div>
                                    <div className="admin-actions">
                                        <button className="admin-button admin-button-secondary" type="button" onClick={lambda (e: MouseEvent) { load_admin(); }}>Refresh content</button>
                                        <button className="admin-button admin-button-secondary" type="button" onClick={lambda (e: MouseEvent) { sign_out(); }}>Sign out</button>
                                    </div>
                                    <p className="admin-notice" role="status" aria-live="polite">{admin_notice}</p>
                                    {if admin_data is not None {
                                        <div className="admin-grid">
                                            <form className="admin-form" onSubmit={save_profile_form}>
                                                <h3>Profile, resume &amp; social links</h3>
                                                <div className="field"><label htmlFor="profile-name">Name</label><input id="profile-name" required maxLength={100} value={full_name} onChange={lambda (e: ChangeEvent) { full_name = e.target.value; }} /></div>
                                                <div className="field"><label htmlFor="profile-role">Role / focus</label><input id="profile-role" maxLength={120} value={role} onChange={lambda (e: ChangeEvent) { role = e.target.value; }} /></div>
                                                <div className="field"><label htmlFor="profile-headline">Hero headline</label><input id="profile-headline" maxLength={240} value={headline} onChange={lambda (e: ChangeEvent) { headline = e.target.value; }} /></div>
                                                <div className="field"><label htmlFor="profile-location">Location</label><input id="profile-location" maxLength={120} value={location} onChange={lambda (e: ChangeEvent) { location = e.target.value; }} /></div>
                                                <div className="field"><label htmlFor="profile-email">Contact email</label><input id="profile-email" type="email" maxLength={254} required value={profile_email} onChange={lambda (e: ChangeEvent) { profile_email = e.target.value; }} /></div>
                                                <div className="field"><label htmlFor="profile-bio">About</label><textarea id="profile-bio" maxLength={3000} rows={4} value={bio} onChange={lambda (e: ChangeEvent) { bio = e.target.value; }}></textarea></div>
                                                <div className="field field-wide"><label htmlFor="sample-content">Sample content is still present</label><input id="sample-content" type="checkbox" checked={sample_content} onChange={lambda (e: ChangeEvent) { sample_content = e.target.checked; }} /></div>
                                                <div className="field"><label htmlFor="profile-skills">Skills (comma-separated)</label><textarea id="profile-skills" rows={2} value={skills_text} onChange={lambda (e: ChangeEvent) { skills_text = e.target.value; }}></textarea></div>
                                                <div className="field"><label htmlFor="profile-experience">Resume entries (Role | Organization | Dates | Summary, one per line)</label><textarea id="profile-experience" rows={4} placeholder="Role | Organization | Dates | Summary" value={experience_text} onChange={lambda (e: ChangeEvent) { experience_text = e.target.value; }}></textarea></div>
                                                <div className="field"><label htmlFor="profile-education">Education (Qualification | Institution | Dates, one per line)</label><textarea id="profile-education" rows={3} placeholder="Qualification | Institution | Dates" value={education_text} onChange={lambda (e: ChangeEvent) { education_text = e.target.value; }}></textarea></div>
                                                <div className="field"><label htmlFor="profile-socials">Social links (Platform | HTTPS URL, one per line)</label><textarea id="profile-socials" rows={3} placeholder="LinkedIn | https://..." value={socials_text} onChange={lambda (e: ChangeEvent) { socials_text = e.target.value; }}></textarea></div>
                                                <button className="admin-button" type="submit" disabled={admin_busy}>{"Saving..." if admin_busy else "Save portfolio content"}</button>
                                            </form>
                                            <div>
                                                <h3>{"Edit project" if project_id else "Add a project"}</h3>
                                                <form className="admin-form" onSubmit={save_project_form}>
                                                    <div className="field"><label htmlFor="project-title">Project title</label><input id="project-title" required maxLength={120} value={project_title} onChange={lambda (e: ChangeEvent) { project_title = e.target.value; }} /></div>
                                                    <div className="field"><label htmlFor="project-category">Category</label><input id="project-category" maxLength={100} value={project_category} onChange={lambda (e: ChangeEvent) { project_category = e.target.value; }} /></div>
                                                    <div className="field"><label htmlFor="project-summary">Summary</label><textarea id="project-summary" required minLength={10} maxLength={1200} rows={3} value={project_summary} onChange={lambda (e: ChangeEvent) { project_summary = e.target.value; }}></textarea></div>
                                                    <div className="field"><label htmlFor="project-year">Year or label</label><input id="project-year" maxLength={20} value={project_year} onChange={lambda (e: ChangeEvent) { project_year = e.target.value; }} /></div>
                                                    <div className="field"><label htmlFor="project-tags">Tags (comma-separated)</label><input id="project-tags" value={project_tags} onChange={lambda (e: ChangeEvent) { project_tags = e.target.value; }} /></div>
                                                    <div className="field"><label htmlFor="project-link">Optional HTTPS project link</label><input id="project-link" type="url" placeholder="https://..." value={project_link} onChange={lambda (e: ChangeEvent) { project_link = e.target.value; }} /></div>
                                                    <div className="admin-actions">
                                                        <button className="admin-button" type="submit" disabled={admin_busy}>{"Update project" if project_id else "Create project"}</button>
                                                        {if project_id {<button className="admin-button admin-button-secondary" type="button" onClick={lambda (e: MouseEvent) { clear_project_form(); }}>Cancel edit</button>}}
                                                    </div>
                                                </form>
                                                <h3>Projects</h3>
                                                <div className="admin-list">
                                                    {for project in admin_data.projects {
                                                        <article className="admin-row" key={jid(project)}>
                                                            <div><strong>{project.title}</strong><p>{project.summary}</p></div>
                                                            <div className="admin-actions">
                                                                <button className="admin-button admin-button-secondary" type="button" onClick={lambda (e: MouseEvent) { edit_project(project); }}>Edit</button>
                                                                <button className="admin-button admin-button-danger" type="button" disabled={admin_busy} onClick={lambda (e: MouseEvent) { remove_project(jid(project)); }}>Delete</button>
                                                            </div>
                                                        </article>
                                                    }}
                                                </div>
                                                <h3>Contact inbox ({len(admin_data.messages)})</h3>
                                                <div className="admin-list">
                                                    {if len(admin_data.messages) == 0 {<p className="empty-state">No messages yet.</p>}}
                                                    {for note in admin_data.messages {
                                                        <article className="admin-row" key={jid(note)}>
                                                            <div>
                                                                <strong>{note.subject}</strong>
                                                                <p>{note.name} / {note.email} / {note.created_at}</p>
                                                                <p className="admin-message">{note.message}</p>
                                                            </div>
                                                            <button className="admin-button admin-button-danger" type="button" disabled={admin_busy} onClick={lambda (e: MouseEvent) { remove_message(jid(note)); }}>Delete message</button>
                                                        </article>
                                                    }}
                                                </div>
                                            </div>
                                        </div>
                                    }}
                                </div>
                            }}
                        </div>
                    </section>
                }}
            </div>
        </div>;
}
