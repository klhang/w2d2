require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
  end
end



class User

  attr_accessor :id, :fname, :lname

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM users WHERE id = ?
    SQL

    User.new(user[0]) if user
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_name(fname, lname)
    users = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    User.new(users[0]) if users
  end

  def authored_questions
    Question.find_by_author_id(@id) if @id
  end

  def authored_replies
    Reply.find_by_user_id(@id) if @id
  end

  def followed_questions
    FollowedQuestions.followed_questions_for_user_id(@id)
  end
end




class Question
  attr_accessor :id, :title, :body, :user_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM questions WHERE id = ?
    SQL

    Question.new(questions[0]) if questions
  end

  def self.most_followed(n)
    FollowedQuestions.most_followed_questions(n)
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL

    questions.map { |options| Question.new(options) }
  end

  def author
    User.find_by_id(@user_id) if @id
  end

  def followers
    FollowedQuestions.followers_for_question_id(@id)
  end



end





class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    question_follows = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM question_follows WHERE id = ?
    SQL

    Question.new(question_follows[0]) if question_follows
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN
        users ON users.id = question_follows.user_id
      WHERE
        question_id = ?
    SQL
    followers.map{|options| User.new(options)}
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN
        questions ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL

    questions.map{ |options| Question.new(options) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.*
    FROM
      question_follows
    JOIN
      questions ON questions.id = question_follows.question_id
    GROUP BY
      question_id
    ORDER BY
      COUNT(*) DESC
    LIMIT ?
    SQL

    questions.map{ |options| Question.new(options) }
  end


end

class Reply
  attr_accessor :id, :question_id, :reply_id, :user_id, :body

  def self.find_by_id(id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM replies WHERE id = ?
    SQL

    Question.new(replies[0]) if replies
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL,user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    replies.map { |options| Reply.new(options) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    replies.map { |options| Reply.new(options) }
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@reply_id)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_id = ?
    SQL
    replies.map {|options| Reply.new(options)}
  end
end


class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    question_likes = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM question_likes WHERE id = ?
    SQL

    Question.new(question_likes[0]) if question_likes
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
