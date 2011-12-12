# NanoDiary

This is a simple DataMapper + Sinatra app to keep a private log of thoughts,
ideas, whatever. Think of it as being like Twitter, except private, text only,
and with no stupid length limit. That is, do the simplest thing, because YAGNI.

Eventually I plan to add some sort of search function. Right now I just wanted
to get the data entry part working.

You will want to password protect it. It has no built-in auth, use 
[Apache .htaccess](http://tools.dynamicdrive.com/password/) or whatever's
appropriate for your hosting environment.

An fcgi script suitable for Apache is supplied. A .htaccess file might look
like this:

    AuthName "Restricted Area"
    AuthType Basic
    AuthUserFile /path/to/htpasswd
    AuthGroupFile /dev/null
    require valid-user
    
    RewriteEngine on
    AddHandler fcgid-script .fcgi
    Options +FollowSymLinks +ExecCGI
    RewriteRule ^(.*)$ dispatch.fcgi [QSA,L]

Once you've got the server side running, there's a trivial RestClient-based 
command-line client in clients/nd. The server provides plain text and JSON APIs
as well as the web UI.

Yes, this is a trivial project. I was surprised I couldn't find something much
better already out there.
