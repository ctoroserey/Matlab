function kprint(h,filename,pictureformat,params)
% function kprint([h],filename,[pictureformat],[params])
% h = graphic handle, optional
% filename
% pictureformat (svg, eps, png, jpg, epsc, ps ... see print)
%               default='png'
% params = printing parameters (see print), optional




if ishandle(h)   % si h est defini
   if nargin<4, params=' '; end

   if sum(size(pictureformat)==[1 3])==2 & sum(pictureformat=='svg')==3, % si svg
          plot2svg([filename '.svg'],h);
   else
%        exportfig(h,filename, 'Format', pictureformat,'Color','rgb');
         eval(['print -f' int2str(h) ' -d' pictureformat ' ' params ' ' filename '.' pictureformat ]);
   end
else
   if nargin==3,params=pictureformat; end
   if nargin==2, params=' '; end
   if nargin==1,
             if length(h>3) & h(end-3)=='.'
              filename=h(end-2:end);
              h=h(1:end-4);
       else
           filename='png';
       end
              params=' ';
   end
   pictureformat=filename;
   filename=h;
     if sum(size(pictureformat)==[1 3])==2 & sum(pictureformat=='svg')==3, % si svg

       plot2svg([filename '.svg']);
         elseif sum(size(pictureformat)==[1 3])==2 & sum(pictureformat=='eps')==3, % si svg

       eval(['print  -depsc2'  params ' ' filename '.eps' ]);
           else
%      exportfig(gcf,[filename '.' pictureformat], 'Format', pictureformat,'Color','rgb');
       eval(['print  -d' pictureformat ' ' params ' ' filename '.' pictureformat ]);
   end
end