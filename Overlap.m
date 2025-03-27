function overlapping=Overlap(point1,point2)
distance=norm(point1.location-point2.location);
overlapping = distance < (point1.radius+point2.radius);
end