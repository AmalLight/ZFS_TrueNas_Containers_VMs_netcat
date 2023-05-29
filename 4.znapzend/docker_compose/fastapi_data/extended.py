from fastapi  import Query                
from typing   import Union                
from pydantic import BaseModel , SecretStr

class get_a_rule_in_this_pc ( BaseModel ) :
  pool_data : str = Query ( "" )

class only_ssh_parameters ( BaseModel ) :
  user : str = Query ( "root"    )
  host : str = Query ( "0.0.0.0" )
  port : int = Query ( 22        )

class get_specific_rule_ssh ( BaseModel ) :
  user      : str = Query ( 'root'    )
  host      : str = Query ( "0.0.0.0" )
  port      : int = Query (  22       )
  pool_data : str = Query ( ""        )
