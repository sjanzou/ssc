			SUBROUTINE TYPE226 (TIME,XIN,OUT,T,DTDT,PAR,INFO,ICNTRL,*) 
C************************************************************************
C Object: Simple Flow Splitter
C Simulation Studio Model: Type226
C 
C Author: Michael J Wagner
C Editor: Michael J Wagner
C Date:	 November 19, 2008 
C Last modified: May 22, 2009
! COPYRIGHT 2009 NATIONAL RENEWABLE ENERGY LABORATORY


! Doc. tables updated 7/1/2010 - MJW
!--------------------------------------------------------------------------------------------------------------------------------------------
! Nb  | Variable                         | Description                                                       | Input units      | Local units      
!--------------------------------------------------------------------------------------------------------------------------------------------
!Parameters
! None

!--------------------------------------------------------------------------------------------------------------------------------------------
! Nb  | Variable                         | Description                                                       | Input units      | Local units      
!--------------------------------------------------------------------------------------------------------------------------------------------
!Inputs
!    1| demand_flow                      | Required flow rate through one branch of the splitter             | kg/hr            | kg/hr            
!    2| total_flow_in                    | Total flow rate into the splitter                                 | kg/hr            | kg/hr            
!    3| T_htf_in                         | Temperature of the fluid into the splitter                        | C                | C                
!    4| disable_bal                      | Flag to disable flow to the balance outlet                        | none             | none             

!--------------------------------------------------------------------------------------------------------------------------------------------
! Nb  | Variable                         | Description                                                       | Input units      | Local units      
!--------------------------------------------------------------------------------------------------------------------------------------------
!Outputs
!    1| T_htf_out                        | Fluid outlet temperature                                          | C                | C                
!    2| demand_flow_out                  | Flow rate out for the demand flow                                 | kg/hr            | kg/hr            
!    3| balance_flow_out                 | Balance of the flow goes to this stream                           | kg/hr            | kg/hr            


C************************************************************************

C    TRNSYS acess functions (allow to acess TIME etc.) 
      USE TrnsysConstants
      USE TrnsysFunctions

C-----------------------------------------------------------------------------------------------------------------------
C    REQUIRED BY THE MULTI-DLL VERSION OF TRNSYS
      !DEC$ATTRIBUTES DLLEXPORT :: TYPE226				!SET THE CORRECT TYPE NUMBER HERE
C-----------------------------------------------------------------------------------------------------------------------
C-----------------------------------------------------------------------------------------------------------------------
C    TRNSYS DECLARATIONS
      IMPLICIT NONE			!REQUIRES THE USER TO DEFINE ALL VARIABLES BEFORE USING THEM

	DOUBLE PRECISION XIN	!THE ARRAY FROM WHICH THE INPUTS TO THIS TYPE WILL BE RETRIEVED
	DOUBLE PRECISION OUT	!THE ARRAY WHICH WILL BE USED TO STORE THE OUTPUTS FROM THIS TYPE
	DOUBLE PRECISION TIME	!THE CURRENT SIMULATION TIME - YOU MAY USE THIS VARIABLE BUT DO NOT SET IT!
	DOUBLE PRECISION PAR	!THE ARRAY FROM WHICH THE PARAMETERS FOR THIS TYPE WILL BE RETRIEVED
	DOUBLE PRECISION STORED !THE STORAGE ARRAY FOR HOLDING VARIABLES FROM TIMESTEP TO TIMESTEP
	DOUBLE PRECISION T		!AN ARRAY CONTAINING THE RESULTS FROM THE DIFFERENTIAL EQUATION SOLVER
	DOUBLE PRECISION DTDT	!AN ARRAY CONTAINING THE DERIVATIVES TO BE PASSED TO THE DIFF.EQ. SOLVER
	INTEGER*4 INFO(15)		!THE INFO ARRAY STORES AND PASSES VALUABLE INFORMATION TO AND FROM THIS TYPE
	INTEGER*4 NP,NI,NOUT,ND	!VARIABLES FOR THE MAXIMUM NUMBER OF PARAMETERS,INPUTS,OUTPUTS AND DERIVATIVES
	INTEGER*4 NPAR,NIN,NDER	!VARIABLES FOR THE CORRECT NUMBER OF PARAMETERS,INPUTS,OUTPUTS AND DERIVATIVES
	INTEGER*4 IUNIT,ITYPE	!THE UNIT NUMBER AND TYPE NUMBER FOR THIS COMPONENT
	INTEGER*4 ICNTRL		!AN ARRAY FOR HOLDING VALUES OF CONTROL FUNCTIONS WITH THE NEW SOLVER
	INTEGER*4 NSTORED		!THE NUMBER OF VARIABLES THAT WILL BE PASSED INTO AND OUT OF STORAGE
	CHARACTER*3 OCHECK		!AN ARRAY TO BE FILLED WITH THE CORRECT VARIABLE TYPES FOR THE OUTPUTS
	CHARACTER*3 YCHECK		!AN ARRAY TO BE FILLED WITH THE CORRECT VARIABLE TYPES FOR THE INPUTS
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    USER DECLARATIONS - SET THE MAXIMUM NUMBER OF PARAMETERS (NP), INPUTS (NI),
C    OUTPUTS (NOUT), AND DERIVATIVES (ND) THAT MAY BE SUPPLIED FOR THIS TYPE
      PARAMETER (NP=0,NI=4,NOUT=3,ND=0,NSTORED=0)
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    REQUIRED TRNSYS DIMENSIONS
      DIMENSION XIN(NI),OUT(NOUT),PAR(NP),YCHECK(NI),OCHECK(NOUT),
	1   STORED(NSTORED),T(ND),DTDT(ND)
      INTEGER NITEMS
C-----------------------------------------------------------------------------------------------------------------------
C-----------------------------------------------------------------------------------------------------------------------
C    ADD DECLARATIONS AND DEFINITIONS FOR THE USER-VARIABLES HERE
C    INPUTS
      DOUBLE PRECISION demand_flow, total_flow_in, T_htf_in, disable_bal
C     OUTPUTS
      DOUBLE PRECISION T_htf_out,demand_flow_out,balance_flow_out
C-----------------------------------------------------------------------------------------------------------------------
C    RETRIEVE THE CURRENT VALUES OF THE INPUTS TO THIS MODEL FROM THE XIN ARRAY IN SEQUENTIAL ORDER

      demand_flow=XIN(1)
      total_flow_in=XIN(2)
      T_htf_in=XIN(3)
      disable_bal=XIN(4)  !1=disable balance flow.. all flow goes to demand.  0=normal operation
	   IUNIT=INFO(1)
	   ITYPE=INFO(2)

C-----------------------------------------------------------------------------------------------------------------------
C    SET THE VERSION INFORMATION FOR TRNSYS
      IF(INFO(7).EQ.-2) THEN
	   INFO(12)=16
	   RETURN 1
	ENDIF
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    DO ALL THE VERY LAST CALL OF THE SIMULATION MANIPULATIONS HERE
      IF (INFO(8).EQ.-1) THEN
	   RETURN 1
	ENDIF
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    PERFORM ANY 'AFTER-ITERATION' MANIPULATIONS THAT ARE REQUIRED HERE
C    e.g. save variables to storage array for the next timestep
      IF (INFO(13).GT.0) THEN
	   NITEMS=0
C	   STORED(1)=... (if NITEMS > 0)
C        CALL setStorageVars(STORED,NITEMS,INFO)
	   RETURN 1
	ENDIF
C
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    DO ALL THE VERY FIRST CALL OF THE SIMULATION MANIPULATIONS HERE
      IF (INFO(7).EQ.-1) THEN

C       SET SOME INFO ARRAY VARIABLES TO TELL THE TRNSYS ENGINE HOW THIS TYPE IS TO WORK
         INFO(6)=NOUT				
         INFO(9)=1				
	   INFO(10)=0	!STORAGE FOR VERSION 16 HAS BEEN CHANGED				

C       SET THE REQUIRED NUMBER OF INPUTS, PARAMETERS AND DERIVATIVES THAT THE USER SHOULD SUPPLY IN THE INPUT FILE
C       IN SOME CASES, THE NUMBER OF VARIABLES MAY DEPEND ON THE VALUE OF PARAMETERS TO THIS MODEL....
         NIN=NI
	   NPAR=NP
	   NDER=ND
	       
C       CALL THE TYPE CHECK SUBROUTINE TO COMPARE WHAT THIS COMPONENT REQUIRES TO WHAT IS SUPPLIED IN 
C       THE TRNSYS INPUT FILE
	   CALL TYPECK(1,INFO,NIN,NPAR,NDER)

C       SET THE NUMBER OF STORAGE SPOTS NEEDED FOR THIS COMPONENT
         NITEMS=0
C	   CALL setStorageSize(NITEMS,INFO)

C       RETURN TO THE CALLING PROGRAM
         RETURN 1

      ENDIF
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    DO ALL OF THE INITIAL TIMESTEP MANIPULATIONS HERE - THERE ARE NO ITERATIONS AT THE INTIAL TIME
      IF (TIME .LT. (getSimulationStartTime() +
     . getSimulationTimeStep()/2.D0)) THEN

C       SET THE UNIT NUMBER FOR FUTURE CALLS
         IUNIT=INFO(1)
         ITYPE=INFO(2)

C       PERFORM ANY REQUIRED CALCULATIONS TO SET THE INITIAL VALUES OF THE OUTPUTS HERE
C		 Fluid outlet temperature
			OUT(1)=290
C		 Flow rate to the tower
			OUT(2)=0
C		 Flow rate to the auxiliary heat source
			OUT(3)=0

C       RETURN TO THE CALLING PROGRAM
         RETURN 1

      ENDIF
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    *** ITS AN ITERATIVE CALL TO THIS COMPONENT ***
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    *** PERFORM ALL THE CALCULATION HERE FOR THIS MODEL. ***
C-----------------------------------------------------------------------------------------------------------------------

      T_htf_out=T_htf_in
      if(disable_bal.eq.0.) then
        demand_flow_out = demand_flow
        balance_flow_out = total_flow_in - demand_flow
      elseif(disable_bal.eq.1.) then
        demand_flow_out = total_flow_in
        balance_flow_out = 0.
      endif 



C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    SET THE OUTPUTS FROM THIS MODEL IN SEQUENTIAL ORDER AND GET OUT

C		 Fluid outlet temperature
			OUT(1)=T_htf_out
C		 Flow rate out for the demand flow
			OUT(2)=demand_flow_out
C		 Balance of the flow goes to this stream
			OUT(3)=balance_flow_out

C-----------------------------------------------------------------------------------------------------------------------
C    EVERYTHING IS DONE - RETURN FROM THIS SUBROUTINE AND MOVE ON
      RETURN 1
      END
C-----------------------------------------------------------------------------------------------------------------------
