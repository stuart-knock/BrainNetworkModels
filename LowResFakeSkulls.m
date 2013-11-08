
%%
 load('Surfaces/Cortex_reg13.mat');
 tr = TriRep(Triangles, Vertices);

 
%%
 K = convhulln(Vertices);
 [B, ~, J] = unique(K);
 

%% 
 FakeInnerSkull.Triangles = reshape(J, size(K));
 FakeInnerSkull.Vertices = 1.25 * Vertices(B,:);

%%
 MaximumEdgeLength = 18; %mm
 NeedsToBeRunAgain = true;

 while NeedsToBeRunAgain,
   InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
   [FakeInnerSkull.Vertices FakeInnerSkull.Triangles NeedsToBeRunAgain] = SplitEdges(InnerSkull, MaximumEdgeLength); 
 end

 
%%
 for k = 1:2,
   InnerSkull = TriRep(FakeInnerSkull.Triangles,FakeInnerSkull.Vertices);
   FakeInnerSkull.Vertices = MoveTowardCentreOfMass(InnerSkull, 0.25);
 end
 
%%
 MaximumEdgeLength = 18; %mm
 NeedsToBeRunAgain = true;

 while NeedsToBeRunAgain,
   InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
   [FakeInnerSkull.Vertices FakeInnerSkull.Triangles NeedsToBeRunAgain] = SplitEdges(InnerSkull, MaximumEdgeLength); 
 end
 
%%  
 for k=1:13,
  %% Reduce degree of high degree vertices.
   InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
   [FakeInnerSkull.Vertices FakeInnerSkull.Triangles] = RemoveSmallDegree3(InnerSkull, 120);

   MaximumDegree = 7;
   EdgesShorterThan = 16;%mm
   ArbitraryBigNumberHack = 424242;
   InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
   [CollapseThese] = GetEdgesToReduceDegree(InnerSkull, MaximumDegree, EdgesShorterThan);
   while ~isempty(CollapseThese),
     [FakeInnerSkull.Vertices FakeInnerSkull.Triangles] = CollapseEdges(InnerSkull, EdgesShorterThan, ArbitraryBigNumberHack, CollapseThese);
     InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
     [CollapseThese] = GetEdgesToReduceDegree(InnerSkull, MaximumDegree, EdgesShorterThan);
   end

  %%
   MinimumEdgeLength = 10; %mm
   NeedsToBeRunAgain = true;

   while NeedsToBeRunAgain,
     InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
     [FakeInnerSkull.Vertices FakeInnerSkull.Triangles NeedsToBeRunAgain] = CollapseEdges(InnerSkull, MinimumEdgeLength); 
   end
   
   %%
   MaximumEdgeLength = 18; %mm
   NeedsToBeRunAgain = true;

   while NeedsToBeRunAgain,
     InnerSkull = TriRep(FakeInnerSkull.Triangles, FakeInnerSkull.Vertices);
     [FakeInnerSkull.Vertices FakeInnerSkull.Triangles NeedsToBeRunAgain] = SplitEdges(InnerSkull, MaximumEdgeLength); 
   end
   
 end
 
%%
 for k = 1:4,
   InnerSkull = TriRep(FakeInnerSkull.Triangles,FakeInnerSkull.Vertices);
   FakeInnerSkull.Vertices = MoveTowardCentreOfMass(InnerSkull, 0.25);
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
  
 
  
  
%% Check resulting surface...
 
 Triangles = FakeInnerSkull.Triangles;
 Vertices = FakeInnerSkull.Vertices;
 tr = TriRep(Triangles, Vertices);
 
 SurfaceSummaryInfo = GetSurfaceSummaryInfo(tr)S
 
 TriangleU = tr.X(tr.Triangulation(:,2),:) - tr.X(tr.Triangulation(:,1),:);
 TriangleV = tr.X(tr.Triangulation(:,3),:) - tr.X(tr.Triangulation(:,1),:);
 TriangleArea = sqrt(sum(cross(TriangleU, TriangleV).^2, 2))./2;
 figure, hist(TriangleArea(:), 100)
 
 SurfaceEdges = edges(tr);
 NumberOfEdges = length(SurfaceEdges);
 EdgeLengths = zeros(1, NumberOfEdges);
 for k = 1:NumberOfEdges,
   EdgeLengths(1, k) = dis(tr.X(SurfaceEdges(k,1),:).', tr.X(SurfaceEdges(k,2),:).');
 end
 figure, hist(EdgeLengths(:), 100)
  
  
 %%%EoF%%%