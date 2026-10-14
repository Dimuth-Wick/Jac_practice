"""Public portfolio data and protected administration endpoints."""

import re;
import from datetime { UTC, datetime }
import from fastapi { HTTPException }
import from jac_scale.user_manager { JacScaleUserManager }
import from pathlib { Path }
import from urllib.parse { urlparse }
import from jaclang { JacRuntime as Jac }
import from uuid { UUID }

node PortfolioProfile {
    has full_name: str = "Sample Name",
        role: str = "Product designer & developer",
        headline: str = "Thoughtful digital experiences, built with care.",
        location: str = "Add your city",
        email: str = "hello@example.com",
        bio: str = "This starter profile uses sample content. Replace it with your own story, experience, and contact details.",
        skills: list[str] = [],
        experience: list[dict[str, str]] = [],
        education: list[dict[str, str]] = [],
        socials: list[dict[str, str]] = [],
        sample_content: bool = True;
}

node PortfolioProject {
    has title: str,
        category: str,
        summary: str,
        year: str,
        tags: list[str] = [],
        link: str = "",
        published: bool = True,
        sort_order: int = 0;
}

node ContactMessage {
    has name: str,
        email: str,
        subject: str,
        message: str,
        created_at: str;
}

obj PortfolioData {
    has profile: PortfolioProfile,
        projects: list[PortfolioProject];
}

obj AdminData {
    has profile: PortfolioProfile,
        projects: list[PortfolioProject],
        messages: list[ContactMessage];
}

obj ActionResult {
    has ok: bool,
        message: str,
        project_id: str = "";
}

glob _admin_manager: JacScaleUserManager = JacScaleUserManager(
    base_path=str(Path.cwd())
);

def _ensure_seeded -> None {
    if len([root.shared -->][?:PortfolioProfile]) > 0 {
        return;
    }

    root.shared ++> PortfolioProfile(
        full_name="Sample Name",
        role="Product designer & developer",
        headline="Thoughtful digital experiences, built with care.",
        location="Add your city",
        email="hello@example.com",
        bio="This starter profile uses sample content. Replace it with your own story, experience, and contact details.",
        skills=[
            "Product thinking",
            "Interaction design",
            "Prototyping",
            "Design systems",
            "Accessible interfaces",
            "Creative development"
        ],
        experience=[
            {
                "role": "Sample role",
                "organization": "Your organization",
                "period": "Add dates",
                "summary": "Replace this sample with a concise description of your responsibilities and impact."
            }
        ],
        education=[
            {
                "qualification": "Your qualification",
                "institution": "Your institution",
                "period": "Add dates"
            }
        ],
        socials=[
            {"label": "LinkedIn", "url": ""},
            {"label": "GitHub", "url": ""},
            {"label": "Behance", "url": ""}
        ],
        sample_content=True
    );
    root.shared ++> PortfolioProject(
        title="Clarity Studio",
        category="Sample case study",
        summary="A sample project card. Replace it with a real project, your role, and the outcome.",
        year="SAMPLE",
        tags=["Research", "Prototyping", "Product design"],
        sort_order=0
    );
    root.shared ++> PortfolioProject(
        title="Local Loop",
        category="Sample concept",
        summary="A second sample card to demonstrate the project layout. No client or results are implied.",
        year="SAMPLE",
        tags=["Community", "Interface design"],
        sort_order=1
    );
    root.shared ++> PortfolioProject(
        title="Open Canvas",
        category="Sample experiment",
        summary="Use the admin editor to add your own work and link to a live project or case study.",
        year="SAMPLE",
        tags=["Creative coding", "Accessibility"],
        sort_order=2
    );
}

def _is_site_admin -> bool {
    admin = _admin_manager.find_user_by_identity("admin");
    if not admin {
        return False;
    }

    user_id = str(admin.get("user_id", ""));
    if not user_id or not _admin_manager.is_admin(user_id) {
        return False;
    }

    admin_root_id = _admin_manager.get_root_id(user_id);
    if admin_root_id is None or jid(root) != admin_root_id {
        return False;
    }

    admin_root_uuid = UUID(admin_root_id);
    for profile in [root.shared -->][?:PortfolioProfile] {
        Jac.allow_root(profile, admin_root_uuid, WritePerm);  # jac:ignore[E1053]
    }
    for project in [root.shared -->][?:PortfolioProject] {
        Jac.allow_root(project, admin_root_uuid, WritePerm);  # jac:ignore[E1053]
    }
    for note in [root.shared -->][?:ContactMessage] {
        Jac.allow_root(note, admin_root_uuid, WritePerm);  # jac:ignore[E1053]
    }
    return True;
}

def _require_site_admin {
    if not _is_site_admin() {
        raise HTTPException(status_code=403, detail="Administrator access required.");
    }
}

def _profile -> PortfolioProfile {
    _ensure_seeded();
    return [root.shared -->][?:PortfolioProfile][0];
}

def _projects(published_only: bool = False) -> list[PortfolioProject] {
    _ensure_seeded();
    result = [p for p in [root.shared -->][?:PortfolioProject] if not published_only or p.published];
    result.sort(key=lambda p: PortfolioProject : p.sort_order);
    return result;
}

"""Return only information intended for public display."""
def:pub get_portfolio -> PortfolioData {
    profile = _profile();
    return PortfolioData(profile=profile, projects=_projects(published_only=True));
}

"""Validate and persist a contact message for the administrator."""
def:pub submit_contact(
    name: str,
    email: str,
    subject: str,
    message: str
) -> ActionResult {
    clean_name = name.strip();
    clean_email = email.strip().lower();
    clean_subject = subject.strip();
    clean_message = message.strip();

    if len(clean_name) < 2 or len(clean_name) > 100 {
        return ActionResult(ok=False, message="Enter a name between 2 and 100 characters.");
    }
    if len(clean_email) > 254 or not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", clean_email) {
        return ActionResult(ok=False, message="Enter a valid email address.");
    }
    if len(clean_subject) < 2 or len(clean_subject) > 120 {
        return ActionResult(ok=False, message="Enter a subject between 2 and 120 characters.");
    }
    if len(clean_message) < 10 or len(clean_message) > 5000 {
        return ActionResult(ok=False, message="Your message must be between 10 and 5000 characters.");
    }

    _ensure_seeded();
    root.shared ++> ContactMessage(
        name=clean_name,
        email=clean_email,
        subject=clean_subject,
        message=clean_message,
        created_at=datetime.now(UTC).isoformat()
    );
    return ActionResult(
        ok=True,
        message="Your message was saved locally for review. No email was sent."
    );
}

"""Return private dashboard data only to the configured Jac Scale admin."""
def:priv get_admin_data -> AdminData {
    _require_site_admin();
    profile = _profile();
    messages = [root.shared -->][?:ContactMessage];
    messages.sort(key=lambda m: ContactMessage : m.created_at, reverse=True);
    return AdminData(profile=profile, projects=_projects(), messages=messages);
}

"""Update the editable profile, resume, skills, and social links."""
def:priv save_profile(
    full_name: str,
    role: str,
    headline: str,
    location: str,
    email: str,
    bio: str,
    sample_content: bool,
    skills: list[str],
    experience: list[dict[str, str]],
    education: list[dict[str, str]],
    socials: list[dict[str, str]]
) -> ActionResult {
    _require_site_admin();

    clean_name = full_name.strip();
    clean_email = email.strip().lower();
    if len(clean_name) < 2 or len(clean_name) > 100 {
        return ActionResult(ok=False, message="Name must be between 2 and 100 characters.");
    }
    if len(clean_email) > 254 or not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", clean_email) {
        return ActionResult(ok=False, message="Enter a valid contact email.");
    }
    if len(headline.strip()) > 240 or len(bio.strip()) > 3000 {
        return ActionResult(ok=False, message="Headline or biography is too long.");
    }
    if (
        len(skills) > 40
        or len(experience) > 30
        or len(education) > 20
        or len(socials) > 20
    ) {
        return ActionResult(ok=False, message="One of the content lists exceeds its allowed size.");
    }
    for social in socials {
        label = social.get("label", "").strip();
        link = social.get("url", "").strip();
        if len(label) < 1 or len(label) > 60 or len(link) > 500 {
            return ActionResult(ok=False, message="Social labels or links exceed their allowed size.");
        }
        if link {
            parsed_link = urlparse(link);
            if (
                parsed_link.scheme != "https"
                or not parsed_link.hostname
                or parsed_link.username
                or parsed_link.password
            ) {
                return ActionResult(ok=False, message="Social links must be valid HTTPS URLs.");
            }
        }
    }

    profile = _profile();
    profile.full_name = clean_name;
    profile.role = role.strip()[:120];
    profile.headline = headline.strip();
    profile.location = location.strip()[:120];
    profile.email = clean_email;
    profile.bio = bio.strip();
    profile.skills = [skill.strip()[:80] for skill in skills if skill.strip()];
    profile.experience = experience;
    profile.education = education;
    profile.socials = socials;
    profile.sample_content = sample_content;
    return ActionResult(ok=True, message="Portfolio content saved.");
}

"""Create a new portfolio project."""
def:priv create_project(
    title: str,
    category: str,
    summary: str,
    year: str,
    tags: list[str],
    link: str
) -> ActionResult {
    _require_site_admin();
    clean_title = title.strip();
    clean_summary = summary.strip();
    clean_link = link.strip();
    if len(clean_title) < 2 or len(clean_title) > 120 {
        return ActionResult(
            ok=False,
            message="Project title must be between 2 and 120 characters."
        );
    }
    if len(clean_summary) < 10 or len(clean_summary) > 1200 {
        return ActionResult(
            ok=False,
            message="Project summary must be between 10 and 1200 characters."
        );
    }
    if clean_link {
        parsed_link = urlparse(clean_link);
        if (
            parsed_link.scheme != "https"
            or not parsed_link.hostname
            or parsed_link.username
            or parsed_link.password
        ) {
            return ActionResult(ok=False, message="Project links must be valid HTTPS URLs.");
        }
    }

    created_project = root.shared ++> PortfolioProject(
        title=clean_title,
        category=category.strip()[:100],
        summary=clean_summary,
        year=year.strip()[:20],
        tags=[tag.strip()[:60] for tag in tags if tag.strip()],
        link=clean_link,
        sort_order=len(_projects())
    );
    grant(created_project[0], level=ReadPerm);
    return ActionResult(ok=True, message="Project created.");
}

"""Update an existing project."""
def:priv update_project(
    project_id: str,
    title: str,
    category: str,
    summary: str,
    year: str,
    tags: list[str],
    link: str
) -> ActionResult {
    _require_site_admin();
    clean_title = title.strip();
    clean_summary = summary.strip();
    clean_link = link.strip();
    if len(clean_title) < 2 or len(clean_title) > 120 {
        return ActionResult(
            ok=False,
            message="Project title must be between 2 and 120 characters."
        );
    }
    if len(clean_summary) < 10 or len(clean_summary) > 1200 {
        return ActionResult(
            ok=False,
            message="Project summary must be between 10 and 1200 characters."
        );
    }
    if clean_link {
        parsed_link = urlparse(clean_link);
        if (
            parsed_link.scheme != "https"
            or not parsed_link.hostname
            or parsed_link.username
            or parsed_link.password
        ) {
            return ActionResult(ok=False, message="Project links must be valid HTTPS URLs.");
        }
    }

    for project in [root.shared -->][?:PortfolioProject] {
        if jid(project) == project_id {
            project.title = clean_title;
            project.category = category.strip()[:100];
            project.summary = clean_summary;
            project.year = year.strip()[:20];
            project.tags = [tag.strip()[:60] for tag in tags if tag.strip()];
            project.link = clean_link;
            return ActionResult(ok=True, message="Project updated.");
        }
    }
    return ActionResult(ok=False, message="Project not found.");
}

"""Delete a project by its stable Jac graph identity."""
def:priv delete_project(project_id: str) -> ActionResult {
    _require_site_admin();
    for project in [root.shared -->][?:PortfolioProject] {
        if jid(project) == project_id {
            del project;
            return ActionResult(ok=True, message="Project deleted.");
        }
    }
    return ActionResult(ok=False, message="Project not found.");
}

"""Delete one reviewed contact message."""
def:priv delete_contact_message(message_id: str) -> ActionResult {
    _require_site_admin();
    for note in [root.shared -->][?:ContactMessage] {
        if jid(note) == message_id {
            del note;
            return ActionResult(ok=True, message="Message deleted.");
        }
    }
    return ActionResult(ok=False, message="Message not found.");
}
