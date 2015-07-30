%VICKY DOAN-NGUYEN 2014%

%CLEARS EVERYTHING
clear;
close all;

files=dir(fullfile('dir','filename'));
%files.name

scale = 1; %unit is pixel per nm

for i = 1:length(files)
    filename=files(i).name
    delimiterIn = '\t';
    %headerlinesIn = 0;
    A = importdata(filename,delimiterIn);
    %A = importdata(filename,delimiterIn,headerlinesIn);
    outfiledistname = sprintf('dist%s',filename);
    outfileedgesname = sprintf('edges%s',filename);
    outfileareasname = sprintf('areas%s',filename);

    outfiledist =fopen(outfiledistname,'w');
    outfileedges=fopen(outfileedgesname,'w');
    outfilearea=fopen(outfileareasname,'w');

%STORES DATA IN ARRAY 
B(:,1)=A(:,2);
B(:,2)=A(:,3);

BB=B(:,1);
CC=B(:,2);
%CALCULATE XY COORDINATE DISTANCES
D = pdist(B,'euclidean')/scale;
distplot = hist(D,max(D));

[v,c]=voronoin([BB,CC]);
[vx,vy] = voronoi(BB,CC);

%CALCULATE AREA
for i=1:length(c)
    ind=c{i}';
    if ind~=1
        voronoiarea(i) = polyarea(v(ind,1),v(ind,2))/(scale*scale);
    end
end



%CALCULATE NUMBER OF EDGES
for i=1:length(c)
arrayofedges(i) = length(c{i});
end

voronoiareapseudomax=0.0000001*max(voronoiarea);
for i = 1:length(voronoiarea)
   if (voronoiarea(i) <= voronoiareapseudomax)
        voronoiareanew(i) = voronoiarea(i);
   end
end

voronoiareanew(voronoiareanew==0)=[];

figure;
plot(vx,vy,'b-');
xlim([0,2048]);
ylim([0,2048]);
axis square;
set(gca,'xtick',[]);
set(gca,'ytick',[]);

figure;
subplot(3,1,1);
voronoi(BB,CC)  
xlim([0,2048]);
ylim([0,2048]);
axis square;

subplot(3,1,2);
histfit(arrayofedges,10,'gamma');
title(sprintf('Edges %s', filename));
xlabel('Number of Edges');
ylabel('Particles');
xlim([0,max(arrayofedges)]);
axis square;
fprintf(outfileedges,'%10.6f\n',arrayofedges);

subplot(3,1,3);
%PLOTS THE DATA IN A BAR PLOT
histfit(D,floor(max(D)),'gamma')
xlabel(sprintf('Distance (nm) %s', filename));
ylabel('Counts');
xlim([0,max(D)]);
axis square;
fprintf(outfiledist,'%10.6f\n',D);

%SAVE FILE TO PDF
saveas(gcf,sprintf('allplots_%s',filename), 'pdf');

end
