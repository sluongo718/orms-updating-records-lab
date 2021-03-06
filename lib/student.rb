require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade 

  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id integer primary key,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table

    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save 
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update 

    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?" 

    DB[:conn].execute(sql, self.name, self.grade, self.id)

  end

  def self.create(n, g)
    kid = Student.new(n, g)
    kid.save
    kid

  end

  def self.new_from_db(row)
    new_stud = self.new(row[0], row[1], row[2])
    
    new_stud
  end

  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM students WHERE name = ?
      LIMIT 1
    SQL
    binding.pry

    DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
    end.first

  end


end
