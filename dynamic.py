"""Demo of pscyopg2 with a dynamic SQL statement, that is, one whose complete
content is not known until we run the code.  This time, the statement is an
INSERT rather than a query, so there are no results to iterate over.
"""

# Import the psycopg2 library.
import psycopg2 as pg

# Create an object that holds a connection to your database.
conn = pg.connect(
    dbname="csc343h-zha10626", user="zha10626", password="",
    options="-c search_path=university,public"
)

# Open a cursor object.
cursor = conn.cursor()

try:
    # Ask the user what course they want to add to the database.
    print('We are going to add a new course!')
    cnum = input('Course number: ')
    name = input('Course name: ')
    dept = input('Department: ')

    # Build up the statement using Python string operations, then execute it.
    # NOTE: We are about to learn that this is the WRONG way of doing this.
    cursor.execute(f"INSERT INTO COURSE VALUES ({cnum}, '{name}', '{dept}');")

    # "Commit" the change to the database. If we don't do this, any changes
    # made by our program are rolled back as if they never happened.
    conn.commit()

except pg.Error as ex:
    print("An Error occurred!")
    print(ex)
    # Handle the error by rolling back.
    # rollback undoes what you were doing when the error was raised. Everything
    # is restored to as it was beforehand.
    # If you plan to continue using the connection later in this program, you
    # must roll back or an error will be raised.
    conn.rollback()

finally:
    # Close the cursor and our connection to the database.
    cursor.close()
    conn.close()

