import os
import webapp2
import jinja2
from datetime import datetime


# https://developers.google.com/appengine/docs/python/urlfetch/
from google.appengine.api import urlfetch
from google.appengine.api import app_identity
from google.appengine.api import users
# https://cloud.google.com/appengine/docs/python/channel/
from google.appengine.api import channel

from google.appengine.ext import ndb
# https://cloud.google.com/appengine/docs/python/ndb/


class HomeHandler(webapp2.RequestHandler):
    def get(self):
        template_values = {'user': 'hello!'
                           }
        template = jinja_environment.get_template('index.htm')
        self.response.out.write(template.render(template_values))

template_dir = os.path.dirname(__file__) + '/templates'
jinja_environment = jinja2.Environment(
    loader=jinja2.FileSystemLoader(template_dir))
# https://webapp-improved.appspot.com/guide/routing.html
app = webapp2.WSGIApplication([
    webapp2.Route(r'/', handler=HomeHandler, name='home')
    ],
    debug=True)
