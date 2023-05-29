from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

from parameters import Parameters
yaml_parameters = Parameters ()

yaml_parameters.read_docker_compose_yml ()

SQLALCHEMY_DATABASE_URL = "postgresql://{}:{}@postgres_fastapi:5432/{}".format (

    yaml_parameters.parsed_yaml [ 'services' ][ 'postgres_fastapi' ][ 'environment' ][ 'POSTGRES_USER'     ] ,
    yaml_parameters.parsed_yaml [ 'services' ][ 'postgres_fastapi' ][ 'environment' ][ 'POSTGRES_PASSWORD' ] ,
    yaml_parameters.parsed_yaml [ 'services' ][ 'postgres_fastapi' ][ 'environment' ][ 'POSTGRES_DB'       ] )

engine = create_engine ( SQLALCHEMY_DATABASE_URL )

SessionLocal = sessionmaker ( autocommit = False , autoflush = False , bind = engine )

Base = declarative_base ()
