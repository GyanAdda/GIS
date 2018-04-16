<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.*,java.util.*"%>
<%@page import="org.json.*" %>
<%
	//String pname=request.getParameter("sname");
	//String pname="Capital police Station";
	try{
		String pname = request.getParameter("sname");
		System.out.println(pname);
		Class.forName("com.mysql.jdbc.Driver");
		Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/giscrimeanalysis", "root", "root");
		Statement st=conn.createStatement();
		String query="select * from crime_data where ps_id in (select ps_id from policestation where policestationname="+"'"+pname+"'"+")";
		PreparedStatement ps=conn.prepareStatement(query);
		ResultSet resultset=ps.executeQuery(query);
		//JSONArray array=new JSONArray();
		JSONObject obj=new JSONObject();
		resultset.next();
		obj.put("riots",resultset.getString("riots"));
		obj.put("accidents",resultset.getString("accidents"));
		obj.put("rape",resultset.getString("rape"));
		obj.put("kidnapping",resultset.getString("kidnapping"));
		obj.put("robbery",resultset.getString("robbery"));
		obj.put("murder",resultset.getString("murder"));
		obj.put("dacoity",resultset.getString("dacoity"));
		obj.put("violent_crime",resultset.getString("violent_crime"));
		obj.put("property_fraud",resultset.getString("property_fraud"));
		//array.put(obj);
		out.println(obj);
		//out.println(name);
	}
	catch(Exception e){
		out.println(e);
	}
%>