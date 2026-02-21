import sys
import os
from unittest.mock import MagicMock
from fastapi.testclient import TestClient

# Mock environment variables BEFORE importing server.app.connect
os.environ["DOCKER_DATABASE_URL"] = "postgresql://mock_user:mock_pass@mock_host:5432/mock_db"

# Mock server.app.connect module to prevent real connection attempt
mock_connect = MagicMock()
mock_connect.engine = MagicMock()
mock_connect.db_session = MagicMock()
sys.modules["server.app.connect"] = mock_connect

# Now import the app
# We need to ensure server module is in path. Since tests/ is at root, and server/ is at root,
# running from root should work if PYTHONPATH includes current dir.
from server.app.main import app, get_db
from server.app.models import Book

# Create a TestClient
client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]

def test_create_book_form():
    response = client.get("/create_book")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]

def test_create_book_api():
    mock_db = MagicMock()
    app.dependency_overrides[get_db] = lambda: mock_db

    response = client.post(
        "/books",
        data={"title": "Test Book", "author": "Test Author", "description": "Test Desc"},
        follow_redirects=False
    )

    # Expect redirect
    assert response.status_code == 303
    assert response.headers["location"] == "/books"

    # Verify DB add/commit/refresh called
    assert mock_db.add.called
    assert mock_db.commit.called
    assert mock_db.refresh.called

def test_list_books():
    mock_db = MagicMock()
    # Mock query result
    mock_book = MagicMock()
    mock_book.title = "Test Book"
    mock_db.query.return_value.all.return_value = [mock_book]

    app.dependency_overrides[get_db] = lambda: mock_db

    response = client.get("/books")
    assert response.status_code == 200
    assert "Test Book" in response.text

def test_read_book():
    mock_db = MagicMock()
    mock_book = MagicMock()
    mock_book.id = 1
    mock_book.title = "Test Book"

    # Mock db.query(Book).filter(Book.id == book_id).first()
    mock_query = mock_db.query.return_value
    mock_filter = mock_query.filter.return_value
    mock_filter.first.return_value = mock_book

    app.dependency_overrides[get_db] = lambda: mock_db

    response = client.get("/books/1")
    assert response.status_code == 200
    assert "Test Book" in response.text

def test_read_book_not_found():
    mock_db = MagicMock()

    # Mock db.query(Book).filter(Book.id == book_id).first()
    mock_query = mock_db.query.return_value
    mock_filter = mock_query.filter.return_value
    mock_filter.first.return_value = None

    app.dependency_overrides[get_db] = lambda: mock_db

    response = client.get("/books/999")
    assert response.status_code == 404
    assert "Book not found" in response.json()["detail"]

def test_update_book_form():
    mock_db = MagicMock()
    mock_book = MagicMock()
    mock_book.id = 1
    mock_book.title = "Original Title"

    mock_query = mock_db.query.return_value
    mock_filter = mock_query.filter.return_value
    mock_filter.first.return_value = mock_book

    app.dependency_overrides[get_db] = lambda: mock_db

    response = client.get("/books/1/update")
    assert response.status_code == 200
    assert "Original Title" in response.text

def test_update_book():
    mock_db = MagicMock()
    mock_book = MagicMock()
    mock_book.id = 1
    mock_book.title = "Original Title"

    mock_query = mock_db.query.return_value
    mock_filter = mock_query.filter.return_value
    mock_filter.first.return_value = mock_book

    app.dependency_overrides[get_db] = lambda: mock_db

    response = client.post(
        "/books/1/update",
        data={"title": "New Title", "author": "New Author", "description": "New Desc"},
        follow_redirects=False
    )

    assert response.status_code == 303
    assert response.headers["location"] == "/books/1"

    assert mock_book.title == "New Title"
    assert mock_db.commit.called

def test_delete_book():
    mock_db = MagicMock()
    mock_book = MagicMock()
    mock_book.id = 1

    mock_query = mock_db.query.return_value
    mock_filter = mock_query.filter.return_value
    mock_filter.first.return_value = mock_book

    app.dependency_overrides[get_db] = lambda: mock_db

    response = client.get("/books/1/delete")
    assert response.status_code == 200

    # Verify delete was called
    # We can't verify exact object unless we check mock_book identity
    assert mock_db.delete.called
    assert mock_db.commit.called
