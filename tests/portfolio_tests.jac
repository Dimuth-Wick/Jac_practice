"""Focused Jac tests for public validation and protected portfolio operations."""

import from fastapi { HTTPException }
import from portfolio_api { get_admin_data, submit_contact }

test "rejects a malformed contact email" {
    result = submit_contact(
        name="Portfolio visitor",
        email="not-an-email",
        subject="A valid subject",
        message="This message is long enough to pass validation."
    );
    assert not result.ok;
    assert result.message == "Enter a valid email address.";
}

test "rejects a contact message that is too short" {
    result = submit_contact(
        name="Portfolio visitor",
        email="visitor@example.com",
        subject="A valid subject",
        message="short"
    );
    assert not result.ok;
    assert result.message == "Your message must be between 10 and 5000 characters.";
}

test "requires the configured admin identity for private content" {
    denied = False;
    try {
        get_admin_data();
    } except HTTPException {
        denied = True;
    }
    assert denied, "A caller outside the admin root must not read portfolio inbox data.";
}
