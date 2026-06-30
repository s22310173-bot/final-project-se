CREATE TABLE status_history (
    id TEXT PRIMARY KEY,
    request_id TEXT NOT NULL,
    old_status TEXT NOT NULL,
    new_status TEXT NOT NULL,
    changed_by TEXT NOT NULL,
    changed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(request_id)
    REFERENCES service_requests(id)
);