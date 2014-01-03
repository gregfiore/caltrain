function [] = pollTwitter()

%     url_data = urlread('http://search.twitter.com/search.json?q=%40from:caltrain');
%     assignin('base','url_data',url_data);
    disp([datestr(now),' Polled Twitter @Caltrain account for updates'])

end