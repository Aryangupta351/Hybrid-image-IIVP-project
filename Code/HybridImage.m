function [] = HybridImage(imgPath1, imgPath2)

    standard_Res = [640 480];
    levels             = 10;
    cutoffFrequency    = 8;
    downsamplingFactor = 0.8;
    upsamplingFactor   = 1/downsamplingFactor;
    
    % Read both input images from the disk
    pictureName1 = strsplit(imgPath1, './input/');
    pictureName1 = strsplit(char(pictureName1(2)), '.'); pictureName1 = pictureName1(1);
    pictureName2 = strsplit(imgPath2, './input/');
    pictureName2 = strsplit(char(pictureName2(2)), '.'); pictureName2 = pictureName2(1);
    picture1     = imread(imgPath1);
    picture2     = imread(imgPath2);

    % Resize both images to given standard resolution
    picture1 = imresize(picture1, standard_Res);
    picture2 = imresize(picture2, standard_Res);

    % Use both images in RGB colorspace and normalise them.
    picture1 = im2double(picture1);
    picture2 = im2double(picture2);

    % Increase the contrast of RGB image that contributes High frequency component.
  
    picture2 = imadjust(picture2, [.2 .3 0; .6 .7 1], []);

    % Align both images together so that algorithm produces better results.
  
    Gaussian_pyramid = GeneratePyramid(picture1, ...
                                      levels, ...
                                      downsamplingFactor, ...
                                      'Gaussian');
  
    % Reconstruct Low frequency component from the first image
    Low_freq    = ReconstructPyramid(Gaussian_pyramid, ...
                                         cutoffFrequency, ...
                                         upsamplingFactor, ...
                                         'Low');
    Low_freq    = imresize(Low_freq, standard_Res);
    
    % Generate 'Laplacian' Pyramid for the second image (High frequency component)
    LaplacianPyramid = GeneratePyramid(picture2, ...
                                       levels, ...
                                       downsamplingFactor, ...
                                       'Laplacian');
  
    % Reconstruct High frequency component from the second image
    High_freq    = ReconstructPyramid(LaplacianPyramid, ...
                                          cutoffFrequency-4, ...
                                          upsamplingFactor, ...
                                          'High');
    High_freq    = imresize(High_freq, standard_Res);

    % Combine Low frequency component of the first image with High frequency component of the second image for creating a Hybrid image.
    hybrid_img = Low_freq + High_freq;
    figure; imshow(hybrid_img);
    imwrite(hybrid_img, char(strcat('HybridImage_', pictureName1, '_', pictureName2, '.jpg')));
    
    % Generate 'Gaussian' Pyramid for a Hybrid image
    HybridGaussian_pyramid  = GeneratePyramid(hybrid_img, ...
                                             cutoffFrequency, ...
                                             downsamplingFactor, ...
                                             'Gaussian');
    pyramid_img            = DisplayPyramid(HybridGaussian_pyramid, ...
                                            size(picture1, 1), ...
                                            3, ...
                                            'Gaussian');
    imwrite(pyramid_img, char(strcat('Gaussian_pyramid_', pictureName1, '_', pictureName2, '.jpg')));

    % Generate 'Laplacian' Pyramid for a Hybrid image
    HybridLaplacianPyramid = GeneratePyramid(hybrid_img, ...
                                             cutoffFrequency, ...
                                             downsamplingFactor, ...
                                             'Laplacian');
    pyramid_img            = DisplayPyramid(HybridLaplacianPyramid, ...
                                            size(picture2, 1), ...
                                            3, ...
                                            'Laplacian');
    imwrite(pyramid_img+0.5, char(strcat('LaplacianPyramid_', pictureName1, '_', pictureName2, '.jpg')));

end


function [pyramid] = GeneratePyramid(img, levels, downsamplingFactor, pyramidType)
    % Create a 'Gaussian' filter with sufficiently large kernel size [25 25] 
    % and standard deviation 5.
    filter = fspecial('gaussian', [25 25], 5);

    % For specified number of levels,
    pyramid = cell(1, levels);
    for i = 1:levels
        % Apply 'Gaussian' filter.If asked for 'Laplacian' pyramid, then subtract filtered image from original image.
        if strcmp(pyramidType, 'Gaussian')
            filtered_img = imfilter(img, ...
                                    filter, ...
                                    'symmetric', ...
                                    'same', ...
                                    'conv');
        elseif strcmp(pyramidType, 'Laplacian')
            filtered_img = img - imfilter(img, ...
                                          filter, ...
                                          'symmetric', ...
                                          'same', ...
                                          'conv');
        end
        
        % Store the filtered image into pyramid
        pyramid{i}   = filtered_img;
        
        % Downsample the filtered image
        img          = imresize(filtered_img, ...
                                downsamplingFactor, ...
                                'bilinear');
    end

end


function [frequency] = ReconstructPyramid(pyramid, ...
                                          cutoffFrequency, ...
                                          upsamplingFactor, ...
                                          frequencyType)

    if strcmp(frequencyType, 'Low')
        Index_start = size(pyramid, 2) - 1;
        Index_end   = size(pyramid, 2) - cutoffFrequency;
    elseif strcmp(frequencyType, 'High')
        Index_start = cutoffFrequency;
        Index_end   = 1;
    end
    
    for i = Index_start:Index_end
        pyramid{i} = pyramid{i} + imresize(pyramid{i+1}, ...
                                           upsamplingFactor, ...
                                           'bilinear');
    end
    
    % Set reconstructed frequency
    frequency = pyramid{Index_end};

end


function [pyramid_img] = DisplayPyramid(pyramid, height, colorChannels, pyramidType)

    % Concatenate every level together (also, pad if required)
    pyramid_img = [];
    for i = 1:size(pyramid, 2)
        tmp_img     = cat(1, ...
                          ones(height - size(pyramid{i},1), ...
                               size(pyramid{i},2), ...
                               colorChannels), ...
                          pyramid{i});
        pyramid_img = cat(2, pyramid_img, tmp_img);
    end
    
    % Display pyramid. If it is a 'Laplacian' pyramid, then add 0.5 before displaying it.
    if strcmp(pyramidType, 'Gaussian')
%         figure; 
%         imshow(pyramid_img);
%         title('Gaussian')
        
    elseif strcmp(pyramidType, 'Laplacian')
%         figure; 
%         imshow(pyramid_img+0.5);
%         title('Laplacian')
        
    end
    
end

