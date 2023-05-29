from SQLdb.database import engine
from SQLdb.tables   import Base
from sqlalchemy     import text

def get_selected_from_db ( selected , from_db ) :

    da_ritorno = ''
    with engine.connect () as connection :

         results = connection.execute ( text ( " SELECT {} FROM {} ".format ( ' , '.join ( selected ) , from_db ) ) )

         for     i1 , result in enumerate   ( results       ) :
             for i2          in range ( len ( result      ) ) :
                 da_ritorno +=          str ( result [ i2 ] ) + ' '

                 if ( i2 == len ( result ) - 1 ) : da_ritorno += '| '

    return da_ritorno [ : -3 ]

def create () :

    with engine.connect () as connection :

         Base.metadata.create_all ( bind = engine )

         connection.execute ( text ( " DROP TABLE zfs_name     " ) )
         connection.execute ( text ( " DROP TABLE zfs_timeline " ) )

         Base.metadata.create_all ( bind = engine )

def clean () :

    with engine.connect () as connection :

         connection.execute ( text ( " DELETE FROM zfs_name     * " ) )
         connection.execute ( text ( " DELETE FROM zfs_timeline * " ) )

         connection.commit ()
