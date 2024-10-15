"""Demo of pscyopg2 where we use a Python dictionary rather than
list indexing to access elements of a results row.  This allows us
to access elements by column name.  This is less error prone than
accessing elements by column number.
"""

# We need a slightly different import statement.
import psycopg2.extras

conn = psycopg2.connect(
    dbname="csc343h-marinat", user="marinat", password="",
    options="-c search_path=university,public"
)

# Create a different kind of cursor object that allows us to access
# results through a Python dictionary.
cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

try:
    cur.execute("SELECT * FROM Student;")
    for record in cur:
        # Here we pull things out of a result row by column name. Nice!
        who = record['sid']
        cgpa = record['cgpa']
        where = record['campus']
        print(f'Student {who} from {where} has a cgpa of {cgpa}.')

finally:
    cur.close()
    conn.close()

