class VerificationQuiz < ActiveRecord::Base

  belongs_to :user

  QUESTIONS = [
    'How long have you been playing Magic?',
    'What is your DCI number?',
    'In what event will you be using the cards?',
    'Is there a local game store where you play?',
    'How did you find out about SpareDeck?'
  ]

end
