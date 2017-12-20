require_relative 'aa_questions'
require_relative 'user'
require_relative 'question'

class QuestionLike
  attr_reader :id, :user_id, :question_id

  def self.find_by_id(id)
    question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL

    return nil if question_like.empty?
    QuestionLike.new(question_like.first)
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    return nil if likers.empty?

    likers.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS count
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    num_likes.first['count']
  end

  def self.liked_questions_for_user_id(user_id)
    liked_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.title, questions.body, questions.id, questions.user_id
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    return nil if liked_questions.empty?

    liked_questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    most_liked = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.title, questions.body, questions.id, questions.user_id, COUNT(*) AS num_likes
      FROM
        questions
      LEFT JOIN
        question_likes ON questions.id = question_likes.question_id
      GROUP BY
        question_id
      ORDER BY
        num_likes DESC
      LIMIT
        ?
    SQL

    return nil if most_liked.empty?

    most_liked.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
