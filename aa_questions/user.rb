require_relative "aa_questions"
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_id(id)

    users = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    return nil if users.empty?

    User.new(users.first)
  end

  def self.find_by_name(fname, lname)
    users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    return nil if users.empty?

    User.new(users.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    avg_karma = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        COUNT(DISTINCT(questions.id)) AS num_questions, COUNT(question_likes.user_id) AS num_likes
      FROM
        questions
      LEFT JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        questions.user_id = ?
      GROUP BY
        questions.id, question_likes.user_id
    SQL

    return 0 if avg_karma.first['num_likes'] == 0

    avg_karma.first['num_questions'] / avg_karma.first['num_likes']
  end
end
