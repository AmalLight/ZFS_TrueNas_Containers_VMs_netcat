import parameters
import json, os, sys, importlib, extended, requests, subprocess, asyncio, numpy , languages

from os.path           import exists
from fastapi           import FastAPI , Request , Query , Depends , Response
from fastapi.responses import HTMLResponse , RedirectResponse , FileResponse

from starlette.staticfiles import StaticFiles

from paramiko import SSHClient , AutoAddPolicy

# -------------------------------------------------------------------------------------------------------

parameters = parameters.Parameters ()
parameters.read_docker_compose_yml ()

app = FastAPI ()

import SQLdb.default
SQLdb.default.create  ()
# SQLdb.default.clean ()

dataset = languages.znapzend ()

print ( 'ZnapZend Manager started' )

# -------------------------------------------------------------------------------------------------------

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware (

    CORSMiddleware ,

    allow_origins     = [ "*" ] ,
    allow_credentials =   True  ,
    allow_methods     = [ "*" ] ,
    allow_headers     = [ "*" ] )

@app.get ( "/root_public_ca_pem" )
async def    root_public_ca_pem  () : return FileResponse ( '/certificates/public-ca.crt' )

from SQLdb.default import get_selected_from_db

@app.get ( '/getNames' )
async def    getNames  () :

      return get_selected_from_db ( [ 'id' , 'name' ] , 'zfs_name' )

@app.get ( '/getTimelines' )
async def    getTimelines  () :

      return get_selected_from_db ( [

             'id' , 'id_zfs_name' , 'date' ,'current_units' ,

             'duration_hours' , 'duration_minutes' , 'duration_seconds' , 
                 'loop_hours' ,     'loop_minutes' ,     'loop_seconds' ] , 'zfs_timeline' )

# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------

def connect ( user , host , cmd , port = 22 ) :
    da_ritorno , client = '' , SSHClient ()
    
    client.load_host_keys ( os.path.expanduser('~') + '/.ssh/known_hosts' )
    client.load_system_host_keys                       ()
    client.set_missing_host_key_policy ( AutoAddPolicy () )

    client.connect ( host , username = user , port = port )
    stdin, stdout, stderr = client.exec_command ( cmd )

    da_ritorno += str ( ':: STDOUT: ' +       stdout.read ().decode ( "utf8" ) [ :-1 ] )
    da_ritorno += str (  '; STDERR: ' +       stderr.read ().decode ( "utf8" ) [ :-1 ] )
    da_ritorno += str (  '; RETURN: ' + str ( stdout.channel.recv_exit_status     () ) )

    stdin.close  ()
    stdout.close ()
    stderr.close ()
    client.close ()

    return da_ritorno

# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------

@app.get ( '/get_snapshots_from_container' )
async def    get_snapshots_from_container  () :

      return_text = subprocess.run ( [ 'zfs' , 'list' , '-t' , 'snapshot' ] , capture_output = True , text = True )
      return Response ( content = return_text.stdout )

@app.get ( '/get_rules_from_container' )
async def    get_rules_from_container  () :

      return_text = subprocess.run ( [ 'znapzendzetup' , 'list' ] , capture_output = True , text = True )
      return  Response ( content = return_text.stdout )

@app.post ( '/get_specific_rule_from_container' )
async def     get_specific_rule_from_container  ( get_a_rule_in_this_pc : extended.get_a_rule_in_this_pc = Depends () ) :

      return_text = subprocess.run ( [ 'znapzendzetup' , 'list' , get_a_rule_in_this_pc.pool_data ] , capture_output = True , text = True )
      return Response ( content = return_text.stdout )

# ----------------------------------------------------------------------------------------------

def str_get_snapshots_ssh   ( only_ssh_parameters      ):
      return_text = connect ( only_ssh_parameters.user ,
                              only_ssh_parameters.host , 'zfs list -t snapshot' , only_ssh_parameters.port )
      return return_text

@app.post ( '/get_snapshots_ssh' )
async def     get_snapshots_ssh  ( only_ssh_parameters : extended.only_ssh_parameters = Depends () ) :

      return Response ( content = str_get_snapshots_ssh ( only_ssh_parameters ) )

@app.post ( '/get_rules_in_ssh' )
async def     get_rules_in_ssh  ( only_ssh_parameters : extended.only_ssh_parameters = Depends () ) :

      return_text = connect ( only_ssh_parameters.user ,
                              only_ssh_parameters.host , 'znapzendzetup list' , only_ssh_parameters.port )

      return Response ( content = return_text )

@app.post ( '/get_specific_rule_ssh' )
async def     get_specific_rule_ssh  ( get_specific_rule_ssh : extended.get_specific_rule_ssh = Depends () ) :

      return_text = connect ( get_specific_rule_ssh.user ,
                              get_specific_rule_ssh.host , 'znapzendzetup list ' + get_specific_rule_ssh.pool_data ,
                              get_specific_rule_ssh.port )

      return Response ( content = return_text )

# ----------------------------------------------------------------------------------------------

@app.post ( '/determine_good_rules_1' )
def           determine_good_rules_1  ( only_ssh_parameters : extended.only_ssh_parameters = Depends () ) :

      rules_txt = connect ( only_ssh_parameters.user ,
                            only_ssh_parameters.host , 'znapzendzetup list' , only_ssh_parameters.port )
      
      subprocess.run ( [ 'mix' , 'local.hex' , '--force' ] , capture_output = True , text = True ,
                                                             cwd = "/fastapi_data/First_project_text_to_json" )

      return_text = subprocess.run ( [ 'mix' , 'run' , './lib/rulestojson.ex' ,
 
                                       rules_txt.replace ( "\n" , "|||" ).replace ( ' ' , '' ) ] ,
                                       capture_output = True , text = True ,
                                       cwd = "/fastapi_data/First_project_text_to_json" )

      return Response ( content = return_text.stdout + "\n" + return_text.stderr )

@app.post ( '/determine_good_rules_2' )
def           determine_good_rules_2  ( only_ssh_parameters : extended.only_ssh_parameters = Depends () ) :

      determine_good_rules_1  ( only_ssh_parameters )
      
      subprocess.run ( [ 'mix' , 'local.hex' , '--force' ] , capture_output = True , text = True ,
                                                             cwd = "/fastapi_data/groupby" )

      return_text = subprocess.run ( [ 'mix' , 'run' , './lib/groupby.ex' ] ,

                                       capture_output = True , text = True , cwd = "/fastapi_data/groupby" )

      return Response ( content = return_text.stdout + "\n" + return_text.stderr )

# ----------------------------------------------------------------------------------------------

def ifstop ( snapshots_list=[], Dseconds = 0, Tseconds = 0, lastElement_match=None, deep=0 ):
    if (snapshots_list == []) or ( Dseconds == 0 ) : return deep
    else:
          Dseconds = Dseconds - ( Dseconds if ( ( Dseconds - Tseconds ) < 0 ) else Tseconds )
          return 0

@app.post ( '/determine_good_rules_3' )
def           determine_good_rules_3  ( only_ssh_parameters : extended.only_ssh_parameters = Depends () ) :

      snapshots_ssh_list = str_get_snapshots_ssh ( only_ssh_parameters ).replace ( '-;' , '-\n;' ).split ( '\n' )[ 1:-1 ]
      snapshots_ssh_list = [  el.split ( ' ' )[ 0 ] for el in snapshots_ssh_list ]

      snapshots_ssh_str  = '\n'.join ( snapshots_ssh_list )

      return_value = "snapshots ssh return:\n" + snapshots_ssh_str + "\n"

      path_json_file = '/fastapi_data/groupby/static/result.json'
      file_rules_2_exists = exists ( path_json_file )

      return_value += "file exists: " + str ( file_rules_2_exists ) + "\n"

      if file_rules_2_exists:
         json_rules_2 = ""

         with open ( path_json_file , "r" ) as f :
              json_rules_2 = json.loads ( f.read () )

         with open ( path_json_file , "r" ) as f :
              return_value += "file's content:\n" + f.read () + "\n"

         for k in json_rules_2.keys ():
             return_value += "pool found: " + k + "\n"
             length_found_pool = len ( json_rules_2 [ k ] )
             return_value += "pool length: " + str ( length_found_pool ) + "\n"

             for i in range ( length_found_pool ):
                 end_bool_str = json_rules_2 [ k ][ i ][ 'end' ]
                 end_bool     = bool ( end_bool_str )

                 limit_bool_str = json_rules_2 [ k ][ i ][ 'limit_good' ]
                 limit_bool     = bool ( limit_bool_str )

                 previous_bool_str = json_rules_2 [ k ][ i ][ 'previous_good' ]
                 previous_bool     = bool ( previous_bool_str )

                 pool_time_rule_str = json_rules_2 [ k ][ i ][ 'time'  ]
                 pool_time_rule     = int ( pool_time_rule_str )

                 pool_prevt_rule_str = json_rules_2 [ k ][ i ][ 'prevt' ]
                 pool_prevt_rule     = int ( pool_prevt_rule_str )

                 pool_class_rule_str = json_rules_2 [ k ][ i ][ 'class' ]
                 pool_prevc_rule_str = json_rules_2 [ k ][ i ][ 'prevc' ]

                 return_value += "pool index: " + str ( i ) +      " end value: " +      end_bool_str + "\n"
                 return_value += "pool index: " + str ( i ) +    " limit value: " +    limit_bool_str + "\n"
                 return_value += "pool index: " + str ( i ) + " previous value: " + previous_bool_str + "\n"
                 
                 return_value += "pool index: " + str ( i ) + " time value: "  + pool_time_rule_str  + "\n"
                 return_value += "pool index: " + str ( i ) + " prevt value: " + pool_prevt_rule_str + "\n"
                 return_value += "pool index: " + str ( i ) + " class value: " + pool_class_rule_str + "\n"
                 return_value += "pool index: " + str ( i ) + " prevc value: " + pool_prevc_rule_str + "\n"

                 if end_bool and limit_bool and previous_bool:

                    collection_deep = numpy.array ( [0] * len ( snapshots_ssh_list ) )

                    Dseconds = 0
                    Tseconds = 0

                    for key , value in dataset.set.items () :
                        if pool_prevc_rule_str in dataset.set [ key ]:
                           if   key == 'minutes' : Dseconds = pool_prevt_rule * 60
                           elif key == 'seconds' : Dseconds = pool_prevt_rule
                           elif key == 'hours'   : Dseconds = pool_prevt_rule * 60**2

                    for key , value in dataset.set.items () :
                        if pool_class_rule_str in dataset.set [ key ]:
                           if   key == 'minutes' : Tseconds = pool_time_rule * 60
                           elif key == 'seconds' : Tseconds = pool_time_rule
                           elif key == 'hours'   : Tseconds = pool_time_rule * 60**2

                    for i in range ( len ( snapshots_ssh_list ) ):

                        collection_deep [i] = ifstop ( snapshots_list = snapshots_ssh_list [ i: ] ,
                                                       Dseconds = Dseconds ,
                                                       Tseconds = Tseconds ,
                                                       lastElement_match = None, deep = 0 )

                    return_value += "collection_deep: " + str ( collection_deep ) + "\n"

      return Response ( content = return_value )
