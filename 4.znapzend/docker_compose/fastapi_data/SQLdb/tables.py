from sqlalchemy     import Boolean, Column, Integer, String, ForeignKey , Date
from SQLdb.database import Base

class ZFS_Name ( Base ) :

     __tablename__ = "zfs_name"

     id   = Column ( Integer , primary_key = True , index = True )
     name = Column ( String  , unique      = True , index = True )

class ZFS_Timeline ( Base ) :

     __tablename__ = "zfs_timeline"

     id          = Column ( Integer , primary_key = True  , index = True )
     id_zfs_name = Column ( Integer , unique      = False , index = True )

     date          = Column ( Date    , unique = False , index = True )
     current_units = Column ( Integer , unique = False , index = True )

     duration_hours   = Column ( Integer , unique = False , index = True )
     duration_minutes = Column ( Integer , unique = False , index = True )
     duration_seconds = Column ( Integer , unique = False , index = True )

     loop_hours   = Column ( Integer , unique = False , index = True )
     loop_minutes = Column ( Integer , unique = False , index = True )
     loop_seconds = Column ( Integer , unique = False , index = True )
