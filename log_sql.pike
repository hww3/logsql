//
// This is a roxen module.
// Uses a pike supported sql database system to log accesses.
// written by Bill Welliver, <hww3@riverweb.com>
//
string cvs_version = "$Id: log_sql.pike,v 1.2 1999-01-13 02:48:53 hww3 Exp $";

#include <module.h>
inherit "module";

object db;		// The db stack
string logtable; 

array register_module()
{
  return ({ MODULE_LOGGER, 
	      "logSQL", 
	      "This logger uses a SQL database server which has pike support, "
	      "to log all accesses for a virtual server.",
	      0,
	      1	
	  });
}

void create()
{
  defvar("dbserver", "localhost", "Database Host", 
	 TYPE_STRING,
	 "This is the name of the host running the SQL server. By using 'localhost' as the value, the same machine that the server is running on (recommended) will be used.\n");
  defvar("dblogin", "", "Database User", 
	 TYPE_STRING,
	 "This is the username with which to connect to the above server.\n");
  defvar("dbpassword", "", "Database password", 
	 TYPE_STRING,
	 "DB User's Password\n");
  defvar("dbcount", 3, "Number of Connections", 
	 TYPE_INT,
	 "Number of connections to make.\n");
  defvar("logdb", "roxen", "Log database", 
	 TYPE_STRING,
	 "This is the database into which all client names will be put.\n");
  defvar("logtable", "access_log", "Log table", 
	 TYPE_STRING,
	 "This is the table into which all client names will be put.\n");
  defvar("failtime", 5,"Warning Timeout",
	TYPE_INT, 
	"Time between reconnect attempts if SQL server is down, in minutes.\n");
}


void start()
{
	string dbserver=query("dbserver");
	if (lower_case(dbserver)=="localhost")
		{ dbserver=""; }
	db=dbstack.db_handler(
                    query("dbserver"),
                    query("logdb"),
                    query("dbcount"),
                    query("dblogin"),
                    query("dbpassword")
                    );   
  logtable=query("logtable");
}

void stop()
{
	destruct(db); 		// We're done, so close the connections.
}
 
// string status()
//  {
// 	string retval;
// 	retval=sql_conn->statistics();
// 	return retval;
//  }

string|void check_variable(string variable, mixed set_to)
{
}


void log(object id, mapping file) 
{
	string log_query;
	object sql_conn=db->handle();
	log_query="INSERT INTO " + logtable+ 
	" VALUES('"+  roxen->quick_ip_to_host(id->remoteaddr) 
+  "',FROM_UNIXTIME("+ id->time  + "),'"+id->not_query+
"','"+id->referer*"" 
+"','"+id->from+"','" +id->client*""+"','" +id->cookies->RoxenUserID 
+ "',"+file->len + ","+(file->error||200) 
+ ",'"+id->method+"')";      
	if(catch(sql_conn->query(log_query)))
	  perror("logSQL: Error running query.\n");		
        db->handle(sql_conn);
	return; 
}
