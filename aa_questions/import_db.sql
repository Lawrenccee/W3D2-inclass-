DROP TABLE IF EXISTS users;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT,
  lname TEXT
);

INSERT INTO
  users(fname,lname)
VALUES
  ('Lawrence', 'Guintu'),
  ('Adrian', 'Horning');

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT,
  body TEXT,
  user_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  questions(title,body,user_id)
VALUES
  (
    'How many licks does it take to get to.....', '1-2-3',
    (SELECT id FROM users WHERE fname = 'Lawrence' AND lname = 'Guintu')
  ),
  (
    'Best Coding Bootcamp?', 'App Academy, Hack Reactor, etc.',
    (SELECT id FROM users WHERE fname = 'Adrian' AND lname = 'Horning')
  );

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (
    (SELECT id FROM users WHERE fname = 'Lawrence' AND lname = 'Guintu'),
    (SELECT id FROM questions WHERE title = 'How many licks does it take to get to.....')
  ),
  (
    (SELECT id FROM users WHERE fname = 'Lawrence' AND lname = 'Guintu'),
    (SELECT id FROM questions WHERE title = 'Best Coding Bootcamp?')
  ),
  (
    (SELECT id FROM users WHERE fname = 'Adrian' AND lname = 'Horning'),
    (SELECT id FROM questions WHERE title = 'Best Coding Bootcamp?')
  );

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  parent_id INTEGER,
  user_id INTEGER,
  body TEXT,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  replies(question_id, parent_id, user_id, body)
VALUES
  (
    (SELECT id FROM questions WHERE title = 'How many licks does it take to get to.....'),
    NULL,
    (SELECT id FROM users WHERE fname = 'Lawrence' AND lname = 'Guintu'),
    'Nice question!'
  ),
  (
    (SELECT id FROM questions WHERE title = 'Best Coding Bootcamp?'),
    NULL,
    (SELECT id FROM users WHERE fname = 'Adrian' AND lname = 'Horning'),
    'Bad Question 😡'
  );

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  question_likes(user_id,question_id)
VALUES
  (
    (SELECT id FROM users WHERE fname = 'Lawrence' AND lname = 'Guintu'),
    (SELECT id FROM questions WHERE title = 'Best Coding Bootcamp?')
  );

INSERT INTO
  replies(question_id, parent_id, user_id, body)
VALUES
  (
    (SELECT id FROM questions WHERE title = 'How many licks does it take to get to.....'),
    (SELECT id FROM replies WHERE body = 'Nice question!'),
    (SELECT id FROM users WHERE fname = 'Adrian' AND lname = 'Horning'),
    'No its not'
  );
