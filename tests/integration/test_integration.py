import os
import sys
import pytest
from fastapi.testclient import TestClient

# We need to make sure we don't use the mocked app from unit tests if running together
# But effectively, we rely on the environment being correct.

# Ensure DOCKER_DATABASE_URL is set, otherwise server.app.connect will exit.
# In CI, this is set. Locally, it might not be.
if "DOCKER_DATABASE_URL" not in os.environ:
    # Set a default or fail?
    # For now let's assume if it's not set, we can't run integration tests.
    pass

try:
    from server.app.main import app
except SystemExit:
    pytest.skip("Database not configured, skipping integration tests", allow_module_level=True)
except ImportError:
     # This might happen if server.app.connect fails to connect and raises exception instead of sys.exit
     pytest.skip("Could not import app, likely DB connection failed", allow_module_level=True)

client = TestClient(app)

def test_integration_workflow():
    # 1. List books - should be empty initially or have content
    response = client.get("/books")
    assert response.status_code == 200
    initial_content = response.text

    # 2. Create a book
    book_data = {
        "title": "Integration Test Book",
        "author": "Integration Author",
        "description": "Created during integration test"
    }
    # Follow redirects to get the list page back
    response = client.post("/books", data=book_data, follow_redirects=True)
    assert response.status_code == 200

    # 3. Verify content
    assert "Integration Test Book" in response.text
    assert "Integration Author" in response.text
