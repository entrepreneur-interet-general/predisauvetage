// Dom7
var $$ = Dom7;

// Framework7 App main instance
var app  = new Framework7({
  root: '#app', // App root element
  id: 'io.framework7.testapp', // App bundle ID
  name: 'Framework7', // App name
  theme: 'auto', // Automatic theme detection
  // App root data
  data: function () {
    return {
      problemes: problemes,
    };
  },
  // App root methods
  methods: {
    helloWorld: function () {
      app.dialog.alert('Hello World!');
    },
  },
  // App routes
  routes: routes,
});

Template7.registerPartial('demander-aide', '<div class="block"><a href="/demander-aide/"><button class="button button-big button-fill color-red">Demander de l\'aide</button></a></div>');

// Init/Create views
app.views.create('#view-home', {
  url: '/'
});
app.views.create('#view-prevention', {
  url: '/prevention/'
});

function findCurrentPosition(output) {
  if (!navigator.geolocation){
    output.html("Votre navigateur ne supporte pas la géolocalisation");
    return;
  }

  function success(position) {
    var latitude  = position.coords.latitude;
    var longitude = position.coords.longitude;

    output.html('Latitude ' + latitude.toFixed(4) + '° Longitude ' + longitude.toFixed(4) + '°');
  }

  function error() {
    output.html("Impossible d'obtenir votre position");
  }

  output.html('<div class="preloader"></div>');

  navigator.geolocation.getCurrentPosition(success, error, { enableHighAccuracy: true });
}

$$(document).on('page:init', '.page[data-name="demander-aide"]', function (e) {
  findCurrentPosition($$("#coordonnees"));
})
