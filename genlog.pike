#!/usr/bin/pike

// genlog.pike
// generate a Common Log file from a LogSQL table.
// usage: genlog.pike tablename numlines
// where tablename is the name of the table to export from
//       numlines is the number of records to export
//
// <hww3@riverweb.com>
//

#define SQLURL "mysql://localhost/roxen"

int main(int argc, string* argv){
  if(sizeof(argv)<2) {
	werror("usage: " + argv[0] + " tablename numlines\n");
	return 1;
	}

  object s=Sql.sql(SQLURL);
// write("running query...");
  object r=s->big_query("select *, DATE_FORMAT(timestmp, '%d/%b/%Y:%H:%i:%S -0500') as t "
" from " + argv[1] + ((argc==3)?(" LIMIT " + argv[2]):""));
// write(" got " + r->num_rows() + " rows.\n");
  mapping row;
  for(int i=0; i<r->num_rows(); i++){
   array rw=r->fetch_row();
        
   if(rw[7]=="404")
    write(rw[0] + " " + rw[3] + " - [" + rw[9] + "] \""
	+ rw[8] + " " + rw[2] + " HTTP/1.0\" 404 -\n");
   else if(rw[7]=="500")  
    write(rw[0] + " " + rw[3] + " ERROR [" + rw[9] + "] \""
	+ rw[8] + " " + rw[2] + " HTTP/1.0\" 500 -\n");
   else
    write(rw[0] + " " + rw[3] + " - [" + rw[9] + "] \""
	+ rw[8] + " " + rw[2] + " HTTP/1.0\" " +
	rw[7] + " " + rw[6] +  "\n");

  }
return 0;
}
