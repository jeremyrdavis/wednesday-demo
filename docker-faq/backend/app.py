import os
import psycopg
from flask import Flask, jsonify

app = Flask(__name__)

DB_CONFIG = {
    'host':     os.environ.get('DB_HOST', 'localhost'),
    'port':     int(os.environ.get('DB_PORT', 5432)),
    'dbname':   os.environ.get('DB_NAME', 'faq'),
    'user':     os.environ.get('DB_USER', 'faq'),
    'password': os.environ.get('DB_PASSWORD', 'faq'),
}


def get_connection():
    return psycopg.connect(**DB_CONFIG)


@app.route('/api/faqs')
def list_faqs():
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute(
            'SELECT id, question, answer, category FROM faqs ORDER BY sort_order, id'
        )
        rows = cur.fetchall()
        cur.close()
        conn.close()
        faqs = [
            {'id': r[0], 'question': r[1], 'answer': r[2], 'category': r[3]}
            for r in rows
        ]
        return jsonify({'faqs': faqs})
    except Exception:
        return jsonify({'faqs': [], 'error': 'database unavailable'}), 503


@app.route('/api/healthz')
def healthz():
    return jsonify({'status': 'ok'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
