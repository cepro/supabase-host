-- setup the database similar to tigerdata cloud
ALTER ROLE postgres WITH NOLOGIN;

CREATE ROLE tsdbadmin WITH
  LOGIN
  PASSWORD 'tsdbadmin'
  NOSUPERUSER
  INHERIT
  CREATEDB
  CREATEROLE
  NOREPLICATION
  NOBYPASSRLS;

CREATE DATABASE tsdb WITH OWNER = tsdbadmin;