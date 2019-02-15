Thermometer = {
  'goal': 1,
  'raised': 0,
  'graphixMax': 100,
  'maskSelector': '.graph #empty',
  'fullSelector': '',
  'invertedSelector': '',
  'mask': null,
  'percentComplete': 0,
  'position': 0,
  'empty': null,
  'full': null,
  'calcByPercent': false,
  'maskType': 'default',
  'timing': 1000,
  'easing': mina.easein,
  'update_callback': function () {
  },
  'name': 'thermometer',
  'calcPercent': function () {
    if (!this.calcByPercent) {
      this.percentComplete = this.raised / this.goal;
    }
  },
  'update': function () {
    this.calcPercent();
    this.position = Math.floor(this.percentComplete * this.graphixMax);
    if (this.position > this.graphixMax) {
      this.position = this.graphixMax;
    }
    transformString = "T0 -" + this.position;
    this.empty.animate({transform: transformString}, this.timing, this.easing);
    this.update_callback();

  },// getData
  'save': function () {
    this.invertedSelector = ".graph #inverted";
    this.empty = Snap(this.maskSelector);
    this.inverted = Snap(this.invertedSelector);
    //var g = s.group(r,c);
    this.inverted.attr({ mask: this.empty });


    this.calcPercent();
  }//init
}

//var empty = Snap(".graph #empty");
//var myMatrix = new Snap.Matrix();


function uCallback() {
  $("#amountraised").val(Thermometer.raised);
}

function getData(amountRaised) {
  var retObject = {};
  goal = updateGoal();
  retObject.percentComplete = amountRaised / goal;
  retObject.position = Math.floor(retObject.percentComplete * graphixMax);
  if (retObject.position > graphixMax) {
    retObject.position = graphixMax;
  }
  transformString = "T0 -" + retObject.position;
  empty.animate({transform: transformString}, 500, mina.easin);
}

function alterMask(type) {
  transformString = "T0 0";
  step = $("#step").val();
  increment = 0;
  switch (type) {
    case 1:
    {
      increment = Thermometer.goal * step;
      break;
    }
    case -1:
    {
      increment = -(Thermometer.goal * step);
      break;
    }
    default:
    {
      break;
    }
  }
  Thermometer.raised = parseInt(Thermometer.raised) + parseInt(increment);
  Thermometer.save();
  Thermometer.update();
}


