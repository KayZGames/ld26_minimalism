part of ld26_minimalism;

Map<String, dynamic> achievements = {
  'wait1' : {
    'check': (GameState gameState) => gameState.waited > 60,
    'desc': 'You have waited 1 minute! Ok, that was easy.',
    'label': 'Novice Waiter',
    'score': 15
  },
  'wait3' : {
    'check': (GameState gameState) => gameState.waited > 180,
    'desc': 'You have waited 3 minutes! Keep waiting!',
    'label': 'Apprentice Waiter',
    'score': 15
  },
  'wait5' : {
    'check': (GameState gameState) => gameState.waited > 300,
    'desc': 'You have waited 5 minutes! Not breaking a sweat.',
    'label': 'Expert Waiter',
    'score': 50
  },
  'wait15' : {
    'check': (GameState gameState) => gameState.waited > 900,
    'desc': 'You have waited 15 minutes! Your patience is great.',
    'label': 'Master Waiter',
    'score': 150
  },
  'wait1190' : {
    'check': (GameState gameState) => gameState.waited > 1190,
    'desc': 'You have waited 1190 seconds! Are you going to wait for it?',
    'label': 'TimeWaiter',
    'score': 250
  },
  'wait60' : {
    'check': (GameState gameState) => gameState.waited > 3600,
    'desc': 'You have waited 1 hour! Better stop now, otherwise you\'ll miss a *ONG.',
    'label': 'GONG',
    'score': 1000
  },
  'hoverStart' : {
    'check': (GameState gameState) => gameState.hoverStart,
    'desc': 'You only have to click it.',
    'label': 'Almost there',
    'score': 1
  },
  'wrongButton' : {
    'check': (GameState gameState) => gameState.wrongButton,
    'desc': 'Are you sure you know what you are doing?',
    'label': 'Too many buttons',
    'score': -3
  },
  'wrongPosition' : {
    'check': (GameState gameState) => gameState.wrongPositionClicked,
    'desc': 'Everything alright?',
    'label': 'Drunken style',
    'score': -3
  },
  'gameStarted' : {
    'check': (GameState gameState) => gameState.running,
    'desc': 'Wow, you must be a bright one!',
    'label': 'Game started',
    'score': 10
  },
  'dodgeNovice' : {
    'check': (GameState gameState) => gameState.dodged > 0,
    'desc': 'You have dodged you first ball! Can you dodge more?',
    'label': 'Novice dodger',
    'score': 10
  },
  'dodgeApprentice' : {
    'check': (GameState gameState) => gameState.dodged > 10,
    'desc': 'You have dodged 10 balls in a row!',
    'label': 'Apprentice dodger',
    'score': 50
  },
  'dodgeExpert' : {
    'check': (GameState gameState) => gameState.dodged > 100,
    'desc': 'You have dodged 100 balls! How are you doing this?',
    'label': 'Expert dodger',
    'score': 250
  },
  'dodgeMaster' : {
    'check': (GameState gameState) => gameState.dodged > 1000,
    'desc': 'You have dodged 1.000 balls without getting hit! Noone can ever hit you.',
    'label': 'Master dodger',
    'score': 5000
  },
  'dodgeBeginner' : {
    'check': (GameState gameState) => gameState.notDodged > 0,
    'desc': 'You have been hit by your first ball. Better start running now!',
    'label': 'The Last Stand',
    'score': -5
  },
  'dodgeLazy' : {
    'check': (GameState gameState) => gameState.notDodged > 10,
    'desc': 'You should at least try to dodge the ball.',
    'label': 'Lazy Mouse',
    'score': -20
  },
  'dodgeRock' : {
    'check': (GameState gameState) => gameState.notDodged > 100,
    'desc': 'You dodge like a rock! Are you even trying?',
    'label': 'The Rock',
    'score': -100
  },
  'negative1' : {
    'check': (GameState gameState) => gameState.score < -10,
    'desc': 'Negative score is BAD. Positive score id GOOD.',
    'label': 'Going backwards',
    'score': -50
  },
  'negative2' : {
    'check': (GameState gameState) => gameState.score < -100,
    'desc': 'Stop that!!.',
    'label': 'Wrong-way driver',
    'score': -200
  },
  'pong1' : {
    'check': (GameState gameState) => gameState.ponged > 0,
    'desc': 'Your first pong',
    'label': 'Ponged',
    'score': 10
  },
  'pong2' : {
    'check': (GameState gameState) => gameState.ponged > 10,
    'desc': 'You ponged ten times in a row!',
    'label': '10 x Ponger',
    'score': 100
  },
  'pong3' : {
    'check': (GameState gameState) => gameState.ponged > 100,
    'desc': 'You ponged 100 times in a row! You seem to be experienced.',
    'label': '100 x Ponger',
    'score': 500
  },
  'lostpong1' : {
    'check': (GameState gameState) => gameState.pongLost > 0,
    'desc': 'Oh no!! You lost you pong!! Now what?',
    'label': 'Wait what?',
    'score': -10
  },
  'lostpong2' : {
    'check': (GameState gameState) => gameState.pongLost > 10,
    'desc': 'That doesn\'t look good, better start stopping the pongs.',
    'label': 'Uh ooh...',
    'score': -50
  },
  'lostpong3' : {
    'check': (GameState gameState) => gameState.pongLost > 100,
    'desc': 'This is not dodgeball! Who do you think retrieves all the pongs.',
    'label': 'Thin like a paper',
    'score': -100
  },
  'block1' : {
    'check': (GameState gameState) => gameState.blocks > 0,
    'desc': 'Finally something to destroy!',
    'label': 'One block down',
    'score': 10
  },
  'block2' : {
    'check': (GameState gameState) => gameState.blocks > 30,
    'desc': 'That\'s the way! Keep on destroying!',
    'label': 'The Turkey',
    'score': 50
  },
  'block3' : {
    'check': (GameState gameState) => gameState.blocks > 100,
    'desc': 'Keep on destroying and I\'ll keep on cheering!',
    'label': 'The Destroyer',
    'score': 500
  },
  'block4' : {
    'check': (GameState gameState) => gameState.blocks > 1000,
    'desc': 'You are the one and only true Master of the Universe!',
    'label': 'You are the man!',
    'score': 5000
  },
  'mover1' : {
    'check': (GameState gameState) => gameState.moved > 10,
    'desc': 'You have to wait for it!',
    'label': 'Stop moving',
    'score': -10
  },
  'mover2' : {
    'check': (GameState gameState) => gameState.moved > 100,
    'desc': 'Just wait! And don\'t move!',
    'label': 'ADHD',
    'score': -100
  }

};