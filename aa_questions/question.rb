require_relative "aa_questions"
require_relative 'user'
require_relative 'question_follow'
require_relative 'question_like'

class Question
  attr_accessor :title, :body
  attr_reader :id, :user_id

  def self.find_by_id(id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    return nil if questions.empty?

    Question.new(questions.first)
  end

  def self.find_by_title(title)
    questions = QuestionsDatabase.instance.execute(<<-SQL, title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = ?
    SQL

    return nil if questions.empty?

    Question.new(questions.first)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL

    return nil if questions.empty?

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionFollow.likers_for_question_id(@id)
  end

  def num_likes
    QuestionFollow.num_likes_for_question_id(@id)
  end

end
