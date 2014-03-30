var app = angular.module('miner', [ 'ngRoute', 'google-maps', 'n3-pie-chart', 'n3-charts.linechart' ]);

app.config(function($routeProvider) {
    $routeProvider.when('/flights', {templateUrl: '/partials/flights.html', controller: 'FlightsController'});
    $routeProvider.when('/flights/p/:page', {templateUrl: '/partials/flights.html', controller: 'FlightsController'});
    $routeProvider.when('/flights/:id', {templateUrl: '/partials/flight.html', controller: 'FlightController'});
    $routeProvider.otherwise({redirectTo: '/flights'});
});

app.controller('FlightsController', [ '$scope', '$http', '$routeParams', function($scope, $http, $routeParams) {
    var _initialize = function() {
        $scope.flights = [];
        $scope.maxPages = 10;
        $scope.currentPage = [];
        $scope.pages = [];
        $scope.currentPage = $routeParams.page ? parseInt($routeParams.page) : 1;
        $scope.pending = true;
        _flights();
    };

    var _flights = function() {
        var url = '/flights.json' + ($routeParams.page ? '?page=' + $routeParams.page : '');
        $http({method: 'GET', url:url}).success(function(data, status, headers, config) {
            angular.forEach(data, function(flights, pages) {
                $scope.pages = [];
                for (var i = 0; i < parseInt(pages); i++) {
                    $scope.pages.push(i)
                }
                $scope.flights = flights;
                $scope.pending = false;
            });
        })
    };

    _initialize();
}]);

app.controller('FlightController', [ '$scope', '$http', '$routeParams', function($scope, $http, $routeParams) {
    var _initialize = function() {
        $scope.center = {latitude:46,longitude:-7};
        $scope.zoom = 4;
        $scope.pending = true;
        $scope.speedData = [];
        $scope.speedOptions = { total: 600, mode: 'gauge', thickness: 5 };
        $scope.lineChartData = [];
        $scope.lineChartOptions = {
            axes: {
                x: {key: 'created_at', type: 'date'},
                y: {type: 'linear'}
            },
            series: [
                {y: 'altitude', color: '#2ecc71', thickness: '2px', striped: true, label: 'Altitude'},
                {y: 'speed', color: '#e67e22', thickness: '2px', striped: true, label: 'Speed'},
                {y: 'vertical_speed', color: '#9b59b6', thickness: '2px', striped: true, label: 'Vertical Speed'},
                {y: 'track', color: '#2c3e50', thickness: '2px', striped: true, label: 'Track'}
            ],
            lineMode: 'linear'
        };
        _flight();
        _snapshots();
    };

    var _flight = function() {
        $http({method: 'GET', url:'/flights/' + $routeParams.id + '.json'}).success(function(data, status, headers, config) {
            $scope.flight = data.flight;
            $scope.speedData.push({label: "Average Speed", value: $scope.flight.average_speed, color: "#2c3e50", suffix: 'km/h'})
        });
    };

    var _snapshots = function() {
        $http({method: 'GET', url:'/flights/' + $routeParams.id + '/snapshots.json'}).success(function(data, status, headers, config) {
            $scope.snapshots = data.snapshots;
            $scope.lineChartData = [];
            angular.forEach($scope.snapshots, function(snapshot, index) {
                $scope.lineChartData.push({speed: snapshot.speed, altitude: snapshot.altitude, created_at: new Date(snapshot.created_at), vertical_speed: snapshot.vertical_speed, track: snapshot.track});
            });
            $scope.center = {latitude: $scope.snapshots[0].latitude, longitude: $scope.snapshots[0].longitude};
            $scope.zoom = 6;
            $scope.pending = false;
        });
    };

    _initialize();
}]);