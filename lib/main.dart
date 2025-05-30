import 'package:flutter/material.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 16),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to the Quiz!')),
      body: AnimatedBackgroundContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Ready to test your knowledge?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizScreen()),
                  );
                },
                child: Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<String> answers;
  final String correctAnswer;

  Question({
    required this.questionText,
    required this.answers,
    required this.correctAnswer,
  });
}

final List<Question> questions = [
  Question(
    questionText: 'What is date of birth of navya?',
    answers: ['may 20', 'june 16', 'may 6', 'january 1'],
    correctAnswer: 'may 6',
  ),
  Question(
    questionText: 'how many chindrens do you have?',
    answers: ['2', '1', '4', '3'],
    correctAnswer: '4',
  ),
  Question(
    questionText: 'whom do you like more?',
    answers: ['lohith', 'thrisha', 'rohith', 'navya'],
    correctAnswer: 'lohith',
  ),
  Question(
    questionText: 'what is your father name?',
    answers: ['surya narayana', 'chandu', 'ramu', 'siva'],
    correctAnswer: 'surya narayana',
  ),
];

class Answer extends StatelessWidget {
  final String answerText;
  final VoidCallback selectHandler;
  final Color backgroundColor;

  Answer({
    required this.answerText,
    required this.selectHandler,
    this.backgroundColor = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectHandler,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
        ),
        child: Text(answerText),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 30;

  String? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      if (_timeLeft > 0 && !_answered) {
        setState(() {
          _timeLeft--;
        });
        _startTimer();
      } else if (!_answered) {
        _answerQuestion('');
      }
    });
  }

  void _answerQuestion(String selectedAnswer) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = selectedAnswer;
      _answered = true;
      if (selectedAnswer == questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });

    Future.delayed(Duration(seconds: 2), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _timeLeft = 30;
        _selectedAnswer = null;
        _answered = false;
      });
      _startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: _score),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Question ${_currentQuestionIndex + 1}')),
      body: AnimatedBackgroundContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _timeLeft / 30,
                color: Colors.indigo,
                backgroundColor: Colors.grey.shade300,
              ),
              SizedBox(height: 10),
              Text('Time Left: $_timeLeft seconds',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion.questionText,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ...currentQuestion.answers.map((answer) {
                Color color = Colors.indigo;
                if (_answered) {
                  if (answer == currentQuestion.correctAnswer) {
                    color = Colors.green;
                  } else if (answer == _selectedAnswer) {
                    color = Colors.red;
                  }
                }
                return Answer(
                  answerText: answer,
                  selectHandler: () => _answerQuestion(answer),
                  backgroundColor: color,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;

  ResultScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Completed')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                  SizedBox(height: 20),
                  Text(
                    'Your Score: $score/${questions.length}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    child: Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedBackgroundContainer extends StatefulWidget {
  final Widget child;

  const AnimatedBackgroundContainer({required this.child});

  @override
  _AnimatedBackgroundContainerState createState() => _AnimatedBackgroundContainerState();
}

class _AnimatedBackgroundContainerState extends State<AnimatedBackgroundContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: Colors.blue.shade200,
      end: Colors.indigo.shade400,
    ).animate(_controller);

    _color2 = ColorTween(
      begin: Colors.purple.shade200,
      end: Colors.deepPurple.shade400,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_color1.value ?? Colors.blue, _color2.value ?? Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
