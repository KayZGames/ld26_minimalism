part of ld26_minimalism;

Map<String, dynamic> achievements = {
  'dummy1' : {
    'check': (GameState gameState) => gameState.waited > 1,
        'desc': 'Lorem Ipsum.',
        'label': 'Dummy 1'
  },
  'dummy2' : {
    'check': (GameState gameState) => gameState.waited > 2,
        'desc': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        'label': 'Dummy 2'
  },
  'dummy3' : {
    'check': (GameState gameState) => gameState.waited > 3,
        'desc': 'Integer eu nisi magna.',
        'label': 'Dummy 3'
  },
  'dummy4' : {
    'check': (GameState gameState) => gameState.waited > 4,
        'desc': 'Maecenas egestas, lacus sed rhoncus elementum, est nibh suscipit nulla, interdum consectetur nisl urna ut nulla.',
        'label': 'Dummy 4'
  },
  'dummy5' : {
    'check': (GameState gameState) => gameState.waited > 5,
        'desc': 'Vivamus sagittis libero sed nulla laoreet varius aliquet nisi ullamcorper.',
        'label': 'Dummy 5'
  },
  'dummy6' : {
    'check': (GameState gameState) => gameState.waited > 6,
        'desc': 'Praesent et arcu eu tortor porttitor viverra.',
        'label': 'Dummy 6'
  },
  'dummy7' : {
    'check': (GameState gameState) => gameState.waited > 7,
        'desc': 'Nulla in tempor justo.',
        'label': 'Dummy 7'
  },
  'dummy8' : {
    'check': (GameState gameState) => gameState.waited > 8,
        'desc': 'Vivamus iaculis aliquam magna, at sollicitudin enim pellentesque convallis.',
        'label': 'Dummy 8'
  },
  'dummy9' : {
    'check': (GameState gameState) => gameState.waited > 9,
        'desc': 'Nunc pretium placerat urna ut convallis.',
        'label': 'Dummy 9'
  },
  'wait1' : {
    'check': (GameState gameState) => gameState.waited > 60,
    'desc': 'You have waited 1 minute! Ok, that was easy.',
    'label': 'Minor Waiter'
  },
  'wait5' : {
    'check': (GameState gameState) => gameState.waited > 300,
    'desc': 'You have waited 5 minutes! Not breaking a sweat.',
    'label': 'Average Waiter'
  },
  'wait15' : {
    'check': (GameState gameState) => gameState.waited > 900,
    'desc': 'You have waited 15 minutes! Your patience is great.',
    'label': 'Great Waiter'
  },
  'wait1190' : {
    'check': (GameState gameState) => gameState.waited > 1190,
    'desc': 'You have waited 1190 seconds! Are you going to wait for it?',
    'label': 'TimeWaiter'
  },
  'wait60' : {
    'check': (GameState gameState) => gameState.waited > 3600,
    'desc': 'You have waited 1 hour! Better stop now, otherwise you\'ll miss a *ONG.',
    'label': 'GONG'
  },
  'hoverStart' : {
    'check': (GameState gameState) => gameState.hoverStart,
    'desc': 'You only have to click it.',
    'label': 'Almost there'
  },
  'wrongButton' : {
    'check': (GameState gameState) => gameState.wrongButton,
    'desc': 'Are you sure you know what you are doing?',
    'label': 'Too many buttons'
  },
  'wrongPosition' : {
    'check': (GameState gameState) => gameState.wrongPositionClicked,
    'desc': 'Everything alright?',
    'label': 'Drunken style'
  },
  'gameStarted' : {
    'check': (GameState gameState) => gameState.running,
    'desc': 'Wow, you must be a bright one!',
    'label': 'Game started'
  }
};