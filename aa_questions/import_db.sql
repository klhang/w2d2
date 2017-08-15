
CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL

);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);


CREATE TABLE replies (
  id INTEGER PRIMARY KEY NOT NULL,
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(reply_id) REFERENCES replies(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('chris', 'guan'), ('alvin','kong'), ('michel','gokan');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('sql', 'how to insert data to sql0',1);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (2, 1);

INSERT INTO
  replies (question_id, reply_id, user_id, body)
VALUES
  (1,1,2,'no comment');

INSERT INTO
  question_likes (question_id, user_id)
VALUES
  (1,2);
