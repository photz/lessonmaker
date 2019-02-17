drop schema if exists minio cascade;
create schema minio;
grant usage on schema minio to public;

create function minio.get_presigned_url(
  bucket_name text,
  object_name text
)
returns text language plpython3u as $$
  from minio import Minio
  from minio.error import ResponseError
  from datetime import timedelta

  plan = plpy.prepare(
    '''select settings.get('minio_host') host, 
              settings.get('minio_port') port, 
              settings.get('minio_access_key') access_key, 
              settings.get('minio_secret_key') secret_key''', [])

  [conf] = plpy.execute(plan, [], 1)

  client = Minio('%s:%s' % (conf['host'], conf['port']),
                 access_key=conf['access_key'],
                 secret_key=conf['secret_key'],
                 secure=False)

  url = client.presigned_put_object(bucket_name,
                                    object_name,
                                    expires=timedelta(hours=1))
  return url
$$;
