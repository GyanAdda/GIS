<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<% Class.forName("com.mysql.jdbc.Driver");
    ArrayList<Float> crime_rate=new ArrayList<Float>();
%>
<html>
<head>
    <title>Crime Zone Mapping</title>
    <meta name="viewport" content="initial-scale=1.0">
    <meta charset="utf-8">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <style>
        /* Always set the map height explicitly to define the size of the div
         * element that contains the map. */
        #map {
            height: 70%;
            width:90%;
        }
        /* Optional: Makes the sample page fill the window. */
        html, body {
            height: 100%;
            margin:0;
            padding: 0;
            background-color:Silver;
        }
        #chart-container{
			width:100%;
		}
		#panel panel-default{
		
			align-content:center;
		}
		.leftcolumn {
    		float: left;
   			 width: 50%;
		}
		.rightcolumn {
    		float: left;
   			 width: 50%;
   			 height:auto;
   			 background-color:white;
		}
		/* Clear floats after the columns */
		.crime-data{
			float:left;
		}
    </style>
    <script type="text/javascript" src="jquery.min.js"></script>
	<script type="text/javascript" src="Chart.min.js"></script>
  	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

</head>
<body>
<div class="container">
  <div class="panel panel-default"><h1>Crime Zone Mapping</h1></div>
</div>
<div class="row">
	<div class="leftcolumn">
		<div id="map"></div>
	</div>
  <div class="rightcolumn">
  		<div id="chart-container">
			<h1>Click on the area to see the Crime Statistics</h1><br>
		</div>
		<div id="info-box"></div>
  		<div id="chart-container">
			<canvas id="mycanvas"></canvas>
		</div>
  </div>
</div>
<div class="crime-table">
    <%
    try{
    		Connection connection = DriverManager.getConnection(
           		 "jdbc:mysql://localhost:3306/giscrimeanalysis", "root", "root");

   			Statement statement = connection.createStatement();
			ResultSet resultset=statement.executeQuery("select c.crime_rate, p.policestationname from crime_data c inner JOIN policestation p ON c.ps_id = p.ps_id ") ;

        	if (!resultset.next()) {
            	out.println("Sorry, some error occured");
        	}
        	else { // ArrayList<String> p_name=new ArrayList<String>();

    %>
	<TABLE align="right" BORDER="1">
        <TR>
            <TH>policestation</TH>
            <TH>crimerate</TH>
        </TR>
       <% while(resultset.next()){
            //  p_name.add(resultset.getString(2));
              crime_rate.add(resultset.getFloat(1));
       %>
        <TR>
            <TD> <%= resultset.getString(2) %> </TD>
            <TD> <%= resultset.getFloat(1) %> </TD>
        </TR>
		<%} %>
    </TABLE>
		
    <%}
      connection.close();
    }catch(Exception e){
    	out.println(e);
    }
    %>
</div>
<script >
    var map;
    function initMap() {
        map = new google.maps.Map(document.getElementById('map'), {
            zoom: 10,
            center: {lat: 20.2661, lng: 85.8245}
        });
        // NOTE: This uses cross-domain XHR, and may not work on older browsers.
        map.data.loadGeoJson(
            'https://raw.githubusercontent.com/datameet/Municipal_Spatial_Data/master/Bhubaneswar/Police_Jurisdiction.geojson');
        var i=0;
        function getColor(d) {
            i++;
            console.log(`${d}`);
            return d > 1.5 ? 'red' :
                d > 0.8  ? 'yellow' :
                    'green';
        }
        var crime=[];
        <%for(int i=0;i<crime_rate.size();i++){%>
           crime.push(<%=crime_rate.get(i)%>);
        <%}%>
        var j=0;
        for(j in crime){
            console.log(`${j}`);
            console.log(`${crime[j]}`);
        }
        map.data.setStyle(function(feature) {
            //var color =   color = feature.getProperty('color');
            //console.log(`${crime[i]}`);
            //i++;
            return /** @type {google.maps.Data.StyleOptions} */({
                          //var c=getColor(crime[i]),
                fillColor: getColor(crime[i]),
                //strokeColor: color,
                strokeWeight: 2
            });
        });
        map.data.addListener('click', function(event) {
        	//var sname=$("#pname").val();
        	document.getElementById('info-box').textContent =
                event.feature.getProperty('Name');
        	var sname=event.feature.getProperty('Name');
    		$.ajax({
    			url:"http://localhost:8080/CrimeDataAnalysis/CrimeDataJson.jsp?sname="+sname,
    			method:"GET", 
    			success:function(result){
    				var data=$.parseJSON(result);
    				console.log(data);
    				var crime=[];
    				var crimeValue=[];
    				crime.push("Riots");
    				crime.push("Accidents");
    				crime.push("Rape");
    				crime.push("Kidnapping");
    				crime.push("Robbery");
    				crime.push("Murder");
    				crime.push("Dacoity");
    				crime.push("Violent Crimes");
    				crime.push("Property Fraud");
    				crimeValue.push(data.riots);
    				crimeValue.push(data.accidents);
    				crimeValue.push(data.rape);
    				crimeValue.push(data.kidnapping);
    				crimeValue.push(data.robbery);
    				crimeValue.push(data.murder);
    				crimeValue.push(data.dacoity);
    				crimeValue.push(data.violent_crime);
    				crimeValue.push(data.property_fraud);
    				var chartdata={
    					labels:crime,
    					datasets:[
    						{
    							label:"",
    							backgroundColor:'rgba(0,200,200,0.75)',
    							borderColor:'rgba(200,0,200,0.75)',
    							hoverBackgroundColor:'rgba(200,200,200,1)',
    							hoverBorderColor:'rgba(200,200,200,1)',
    							data:crimeValue
    						}
    					]
    				};
    				var ctx=$("#mycanvas");
    				
    				var barGraph=new Chart(ctx,{
    					type:'bar',
    					data:chartdata	
    				});
    				
    			},
    			error:function(data){
    				console.log(data);
    			}
    		});
    	
        });


        map.data.addListener('mouseover', function (event) {
             })
      }
</script>
<script async defer
        src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCL-XdIIfPKPPnXesXHXjYufXdSLoEJ04Y&callback=initMap">
</script>

</body>
</html>