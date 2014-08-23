      
module InputData
    
    type InputVariablesData
    
        real :: Ma                      ! Mach number
        real :: xmax                    ! Maximum horizontal displacement of Control Nodes
        real :: ymax                    ! Maximum vertical displacement of Control Nodes
        real :: zmax                    ! Maximum lateral displacement of Control Nodes
        real :: gamma                   ! Ratio of specific heats
        real :: R                       ! specific gas constant
        real :: Tamb					! ambient Temperature [K]
        real :: Pamb    				! ambient Pressure [Pa]
        real :: engFMF                  ! Solver variable - engines Front Mass Flow
        real :: Top2Low                 ! Fraction of Top to Low Nests
        integer :: NoNests              ! Number of Nests (Cuckoo Search)
        integer :: NoSnap               ! Number of initial Snapshots
        integer :: NoCP                 ! Number of Control Points
        integer :: NoDim                ! Number of Dimensions
        integer :: NoG                  ! Number of Generations
        integer :: NoPOMod              ! No of POD Modes considered
        integer :: NoLeviSteps          ! Number of Levy walks per movement
        integer :: NoIter               ! Batch File variable - Number of Iterations    
        logical :: constrain            ! Constrain: Include boundaries of design space for Levy Walk - 1:Yes 0:no
        logical :: AdaptSamp            ! Adaptive Sampling - T: Active
        integer :: delay                ! Delay per check in seconds
        integer :: waitMax              ! maximum waiting time in hours
        real :: Aconst                  ! Levy Flight parameter (determined emperically)   
        character(len=20) :: filename    ! I/O file of initial Meshes for FLITE solver
        character :: runOnCluster       ! Run On Cluster or Run on Engine?
        character :: SystemType         ! Windows('W'), Cluster/QSUB ('Q') or HPCWales/BSUB ('B') System? (Cluster, HPCWales = Linux, Visual Studio = Windows)    
        character(len=20) :: UserName    ! Putty Username - Cluster: egnaumann
        character(len=20) :: Password    ! Putty Password
        character(len=3) :: version
        character(len=4) :: MeshGeneration
        logical :: Meshtest
        logical :: AllSurface
        logical :: Pol                  ! POD using Polynomial
        logical :: sort                 ! POD sorting the Snapshots
        logical :: OldvsNew
        logical :: multiquadric         ! RBF type for POD
        logical :: POD
        
        character(len=5) :: GeomType
        real, dimension(4) :: BoundDomain
        logical :: MoveAllGeom                             ! Is all the geometry moving?
    
    end type InputVariablesData
    
    type(InputVariablesData) :: IV
    integer :: allocatestatus                                   ! Check Allocation Status for Large Arrays
    character(len=10) :: InFolder = 'Input_Data'                ! Input Folder Name
    character(len=11) :: OutFolder = 'Output_Data'              ! Output Folder Name
    integer :: IntSystem                                        ! Length of System command string; used for character variable allocation
    integer :: maxDoF                                           ! maximum Degrees of Freedom available
    integer :: DoF                                              ! actual Degrees of Freedom in the System
    integer :: av                                               ! Allocater Variable
    real :: waitTime                                            ! waiting time for Simulation Results
    integer :: jobcheck                                         ! Check Variable for Simulation 
    character(len=:), allocatable :: istr                       ! Number of I/O file
    character(len=21) :: pathWin                                ! Path to Windows preprocessor file
    character(len=:), allocatable :: pathLin_Prepro             ! Path to Linux preprocessor file
    character(len=:), allocatable :: pathLin_Solver             ! Path to Linux Solver file
    character(len=:), allocatable :: strSystem                  ! System Command string for communication with FLITE Solver
    character(len=8) :: date                                    ! Container for current date
    character(len=10) :: time                                   ! Container for current time
    character(len=35) :: newdir                                 ! Name of new folder for a new Solution generated by 2D solver
    double precision :: alpha, beta                             ! Matrix Multiplicaion LAPACK variables
    
contains
    
    subroutine SubInputData(IV)
    
        ! Variables
        implicit none
        type(InputVariablesData) :: IV
    
        ! Body of SubInputData
        namelist /InputVariables/ IV
    
        IV%Ma = 0.5  		            ! Mach number
        IV%Tamb = 30					! ambient Temperature [deg]
        IV%Pamb = 101325				! ambient Pressure [Pa]
        IV%R = 287                  	! specific gas constant
        IV%gamma = 1.4                  ! Ratio of specific heats
        IV%xmax = 0.00			        ! Maximum horizontal displacement of Control Nodes    
        IV%ymax = 0.02			        ! Maximum vertical displacement of Control Nodes    
        IV%zmax = 0.00			        ! Maximum lateral displacement of Control Nodes    
        IV%engFMF = 1.0			        ! engines Front Mass Flow(Solver variable)
        IV%Top2Low = 0.75		        ! Fraction of Top to Low Cuckoo Nests
        IV%NoSnap = 1000                ! Number of initial Snapshots
        IV%NoCP = 7			            ! Number of Control Points 
        IV%NoDim = 2			        ! Number of Dimensions in Space 
        IV%NoG = 100		            ! Number of Generations
        IV%NoNests = 0                  ! Number of Nests (Cuckoo Search)
        IV%NoPOMod = -1			        ! No of POD Modes considered 
        IV%NoLeviSteps = 100         	! Number of Levy walks per movement 
        IV%NoIter = -3               	! Batch File variable - Number of Iterations 
        IV%constrain = .TRUE.         	! Constrain: Include boundaries of design space for Levy Walk - 1:Yes 0:no
        IV%delay = 300               	! Sleep Time between check for Simulation Results in seconds
        IV%waitMax = 48			        ! maximum waiting time in hours
        IV%Aconst = 0.01		        ! Levy Flight parameter (determined emperically)
        IV%filename = 'Snapshot'        ! I/O file of initial Meshes for FLITE solver
        IV%runOnCluster = 'Y'           ! Run On Cluster or Run on Engine?
        IV%SystemType = 'Q'             ! Windows('W'), Cluster/QSUB ('Q') or HPCWales/BSUB ('B') System? (Cluster, HPCWales = Linux, Visual Studio = Windows)
        IV%UserName = 'egnaumann'       ! Putty Username - Cluster: egnaumann
        IV%Password = 'Fleur666'        ! Putty Password
        IV%version = '1.8'
        
        ! TESTING
        IV%Pol = .true.                 ! Application of Polynomial?
        IV%sort = .false.               ! Test sort algorithm to old algorithm
        IV%OldvsNew = .false.           ! Test old vs new POD algorithm
        IV%multiquadric = .true.        ! using multiquadratic RBF function for POD
        
        IV%AdaptSamp = .FALSE.          ! Adaptive Sampling - T: Active
        IV%POD = .true.                 ! Activation of POD - TRUE is ACTIVE
        
        ! For Mesh Deformation
        IV%MeshGeneration = 'RBF'
        IV%Meshtest = .true.
        IV%AllSurface = .false.
        IV%BoundDomain = (/10, -10, 10, -10/)
        IV%GeomType = 'close'
        IV%MoveAllGeom = .true.
        
        open(1,file = InFolder//'/AerOpt_InputParameters.txt',form='formatted',status='old')
        read(1,InputVariables)
        close(1)
        
        ! Derive Degrees of Freedom
        av = 0
        if (IV%xmax /= 0.00) then
            av = av + 1
        end if
        if (IV%ymax /= 0.00 .and. IV%NoDim > 1) then
            av = av + 1
        end if
        if (IV%zmax /= 0.00 .and. IV%NoDim == 3) then
            av = av + 1
        end if
        DoF = av*IV%NoCP
        maxDoF = IV%Nodim*IV%NoCP
        
        ! Number of Nests per Generation 
        IV%NoNests = 10*DoF     
        if (IV%NoNests > IV%NoSnap) then
            IV%NoNests = IV%NoSnap
        end if
        
        ! Path for PreProcessor
        if (IV%SystemType == 'Q') then
            allocate(character(len=61) :: pathLin_Prepro)
            pathLin_Prepro = '/eng/cvcluster/'//trim(IV%UserName)//'/AerOpt/PrePro/2DPreProcessorLin'
        else
            allocate(character(len=56) :: pathLin_Prepro)
            pathLin_Prepro = '/home/'//trim(IV%UserName)//'/AerOpt/PrePro/2DPreProcessorLin'
        end if
        pathWin = 'Flite2D\PreProcessing'   
   
        ! Path for Solver
        if (IV%SystemType /= 'B') then
            allocate(character(len=55) :: pathLin_Solver)
            pathLin_Solver = '/eng/cvcluster/'//trim(IV%UserName)//'/AerOpt/Solver/2DSolverLin'
        else
            allocate(character(len=50) :: pathLin_Solver)
            pathLin_Solver = '/home/'//trim(IV%UserName)//'/AerOpt/Solver/2DSolverLin'
        end if
        
    end subroutine SubInputData
    
end module InputData