import subprocess
from qutebrowser.api import interceptor

c.aliases = {
    'q': 'quit',
    'w': 'session-save',
    'wq': 'quit --save',
    'x': 'quit --save',
    'o': 'open',
    'bmark': 'bookmark-add',
}

c.downloads.location.directory = "/home/lain/net"
config.load_autoconfig(False)
config.bind(',v', 'hint links spawn mpv {hint-url}')
config.bind(',V', 'hint links spawn feh {hint-url}')

def filter_yt(info: interceptor.Request):
    """Block the given request if necessary."""
    url = info.request_url
    if (
        url.host() == "www.youtube.com"
        and url.path() == "/get_video_info"
        and "&adformat=" in url.query()
    ):
        info.block()

interceptor.register(filter_yt)

c.tabs.show = "multiple"
c.tabs.title.format = "{audio}{current_title}"
c.fonts.web.size.default = 20
c.scrolling.smooth = True
c.colors.webpage.darkmode.enabled = True

c.content.default_encoding = 'utf-8'
c.downloads.position = 'bottom'

c.auto_save.session = False

c.statusbar.widgets = ['keypress', 'url', 'history', 'tabs', 'progress']
c.content.cookies.accept = 'no-3rdparty'
c.content.geolocation = False
c.content.pdfjs = False
c.content.autoplay = False

c.content.blocking.method = 'both'
c.content.media.audio_capture = False
c.content.media.audio_video_capture = False
c.content.media.video_capture = False
c.content.prefers_reduced_motion = True
c.content.desktop_capture = False
c.content.headers.do_not_track = True
c.content.headers.referer = 'same-domain'
c.content.webgl = False


c.completion.delay = 0

c.fonts.default_family = "Meslo LG S Nerd Font"
