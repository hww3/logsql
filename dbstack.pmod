#if constant(thread_create)
static inherit Thread.Mutex;
#define THREAD_SAFE
#define LOCK() do { object key; catch(key=lock())
#define UNLOCK() key=0; } while(0)
#else
#undef THREAD_SAFE
#define LOCK() do {
#define UNLOCK() } while(0)
#endif

class db_handler
{
#ifdef THREAD_SAFE
      static inherit Thread.Mutex;
#endif
      array (object) dbs = ({});
      string db_name, db_user, db_password, host;
      int num_dbs;  
      void create(string|void _host, string _db, int num, string|void _user,
                  string|void _password) {
         db_name = _db;
         host = _host;
         db_user = _user;
         db_password = _password;
         num_dbs=num;
         mixed err;
         for(int i = 0; i < num; i++) {
            err=catch( dbs += ({ Sql.sql(host, db_name, db_user, db_password) }));
            if(err)
               perror("Error creating db object:\n" +
                      describe_backtrace(err)+"\n");
         }
      }
       
      void|object handle(void|object d)
      {
         LOCK();
         int count;
         dbs -= ({0});
         if(objectp(d)) {
            // werror("returning a db object...\n");
            if(search(dbs, d) == -1) {
               if(sizeof(dbs)>(2*num_dbs)) {
                  werror("Dropping db because of inventory...\n");
                  destruct(d);
               }
               else {
                  dbs += ({d});
                  //werror("Handler ++ ("+sizeof(dbs)+")\n");
               }
            }
            else {
//               werror("Handler: duplicate return: \n");
            }
            //      destruct(d);
         } 

         else {
            // werror("requesting a db object...\n");
            if(!sizeof(dbs)) {
               werror("Handler: New DB created (none left).\n");
               d = Sql.sql(host, db_name, db_user, db_password);
               //d->set_timeout(60);
            } else {
               d = dbs[0];
               dbs -= ({d});
               //werror("Handler -- ("+sizeof(dbs)+")\n");
            }
         }
         UNLOCK();
         return d;
      }
}



