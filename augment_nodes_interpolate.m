% Jason Manning and Adam Rauff

% The purpose of this function is to create data nodes along the edge of
% the image for the interpolation process. The data at the sub-block nodes
% is extended to the edge of the image boundaries. This increases the
% amount of data used during the interpolation of sampled points,
% decreasing the number of samples yielding NaN results.

function [anisotropy_inter, vectorx_interp, vectory_interp] = ...
    augment_nodes_interpolate(Neovessel, sampled_x, sampled_y)

%% extract relevant vars from structure
image = Neovessel.shg;
[m n] = size(image);

node_x = Neovessel.node_pix(:,:,1);
node_y = Neovessel.node_pix(:,:,2);

% anisotropy and fibril direction vectors at nodes
node_aniso = Neovessel.anisotropy;
node_vecx = Neovessel.vector_x;
node_vecy = Neovessel.vector_y;

%% augment the data around the image edges
% add x locations at the start and end of the image
aug_x = [ones(size(node_x,1), 1), node_x, ones(size(node_x,1), 1)*n];
% duplicate the first and last rows
aug_x = [aug_x(1,:); aug_x; aug_x(end,:)];

% add y locations at the start and end of the image
aug_y = [ones(1, size(node_x,2)); node_y; ones(1,size(node_x,2))*m];
aug_y = [aug_y(:,1), aug_y, aug_y(:,end)];

% augment all 4 sides of the anisotropy and vectors matrices to account for
% the added locations around the edge of the image - copy nearest node data
aug_aniso = [node_aniso(:,1), node_aniso, node_aniso(:,end)];
aug_aniso = [aug_aniso(1,:); aug_aniso; aug_aniso(end,:)];

aug_vecx = [node_vecx(:,1), node_vecx, node_vecx(:,end)];
aug_vecx = [aug_vecx(1,:); aug_vecx; aug_vecx(end,:)];

aug_vecy = [node_vecy(:,1), node_vecy, node_vecy(:,end)];
aug_vecy = [aug_vecy(1,:); aug_vecy; aug_vecy(end,:)];


%% interpolations
% interpolate the anisotropy 
% linear interpolation of the scalar value
anisotropy_inter = interp2(aug_x, aug_y, aug_aniso, sampled_x, sampled_y);

% interpolate the fibril direction
% interpolate the x and y components of the vectors independently
vectorx_interp = interp2(aug_x, aug_y, aug_vecx, sampled_x, sampled_y);
vectory_interp = interp2(aug_x, aug_y, aug_vecy, sampled_x, sampled_y);

end


