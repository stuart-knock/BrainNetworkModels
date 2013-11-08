
%%
 load('Surfaces/Cortex_reg17.mat');
 tr = TriRep(Triangles, Vertices);

 
%%
 K = convhulln(Vertices);
 [B, ~, J] = unique(K);
 

%% 
 FakeInnerSkull.Triangles = reshape(J, size(K));
 FakeInnerSkull.Vertices = 1.025 * Vertices(B,:);
 

%%
 MaximumEdgeLength = 8; %mm
 NeedsToBeRunAgain = true;

 while NeedsToBeRunAgain,
   InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
   [FakeInnerSkull.Vertices FakeInnerSkull.Triangles NeedsToBeRunAgain] = SplitEdges(InnerSkull, MaximumEdgeLength); 
 end
 
 
%%
 MinimumEdgeLength = 2; %mm
 NeedsToBeRunAgain = true;

 while NeedsToBeRunAgain,
   InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
   [FakeInnerSkull.Vertices FakeInnerSkull.Triangles NeedsToBeRunAgain] = CollapseEdges(InnerSkull, MinimumEdgeLength); 
 end
 
 
%%
 for k = 1:4,
   InnerSkull = TriRep(FakeInnerSkull.Triangles,FakeInnerSkull.Vertices);
   FakeInnerSkull.Vertices = MoveTowardCentreOfMass(InnerSkull, 0.25);
 end
 
 
%%
 MaximumArea = 20;
 
 InnerSkull = TriRep(FakeInnerSkull.Triangles,FakeInnerSkull.Vertices);
 [FakeInnerSkull.Vertices FakeInnerSkull.Triangles] = RemoveSmallDegree3(InnerSkull, MaximumArea);
 
 
 %% Split longest edge of smallest triangles...
 MinimumTriangleSize = 4;
 AreaRatio = 0.5;

 InnerSkull = TriRep(FakeInnerSkull.Triangles,FakeInnerSkull.Vertices);
 
 [LittleTrianglesGlobalIndex LittleTriangleArea] = GetLittleTriangles(InnerSkull, MinimumTriangleSize);
 [ShortestEdgesGlobalIndex LongestEdgesGlobalIndex ShortestEdgesLength LongestEdgesLength] = GetShortLongEdges(InnerSkull, LittleTrianglesGlobalIndex);
 
 SplitThese = LongestEdgesGlobalIndex((LittleTriangleArea.' ./ ((ShortestEdgesLength.^2) ./ 2)) < AreaRatio, :);
 
 [FakeInnerSkull.Vertices FakeInnerSkull.Triangles ] = SplitEdges(InnerSkull, 0, 0, SplitThese);
 
%%
 for k = 1:2,
   InnerSkull = TriRep(FakeInnerSkull.Triangles,FakeInnerSkull.Vertices);
   FakeInnerSkull.Vertices = MoveTowardCentreOfMass(InnerSkull, 0.25);
 end
 
%% Hard limit minimum edge length
 MinimumEdgeLength = 2.25; %mm
 NeedsToBeRunAgain = true;
 
 while NeedsToBeRunAgain,
   InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
   [FakeInnerSkull.Vertices FakeInnerSkull.Triangles NeedsToBeRunAgain] = CollapseEdges(InnerSkull, MinimumEdgeLength);
 end
 
 
%% 
 MaximumEdgeLength = 8.0;%mm
 NeedsToBeRunAgain = true;
 while NeedsToBeRunAgain,
   InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
   [FakeInnerSkull.Vertices FakeInnerSkull.Triangles NeedsToBeRunAgain] = SplitEdges(InnerSkull, MaximumEdgeLength, 2^12 - length(FakeInnerSkull.Vertices));%
 end

 
 %%
  FakeOuterSkull.Vertices = 1.02*FakeInnerSkull.Vertices;
  FakeOuterSkin.Vertices  = 1.03*FakeInnerSkull.Vertices;
 
  
 %% InnerSkull
  Vertices = FakeInnerSkull.Vertices;
  Triangles = FakeInnerSkull.Triangles;
  save('Surfaces/InnerSkull_4096.mat', 'Vertices', 'Triangles')
 
 %% OuterSkull
  Vertices = FakeOuterSkull.Vertices;
  save('Surfaces/OuterSkull_4096.mat', 'Vertices', 'Triangles')
  
 
 %% OuterSkin
  Vertices = FakeOuterSkin.Vertices;
  save('Surfaces/OuterSkin_4096.mat', 'Vertices', 'Triangles')
  
 
 %%%EoF%%%