require_relative "aa_questions"
require_relative 'user'

class QuestionFollow
  attr_reader :id, :user_id, :question_id

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL

    return nil if followers.empty?

    followers.map { |follower| User.new(follower) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.title, questions.id, questions.body, questions.title
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL

    return nil if questions.empty?

    questions.map { |q| Question.new(q) }
  end

  def self.most_followed_questions(n)

    most_followed_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.title, questions.id, questions.body, questions.user_id, COUNT(*) AS num_followers
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL

    return nil if most_followed_questions.empty?

    most_followed_questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end


end
