subroutine turbuflux(ia,ja,ka,rr,dtmin,Ah,imt,jmt,km,uflux,vflux,wflux,ff,upr)
!KMT had to move this inside subroutine
#ifdef turb    
  
  ! computes the paramterised turbulent velocities u' and v' into upr

!!
!!
!! Output:
!!  upr     uprime

implicit none
 
real*8, intent(out), dimension(6,2) :: upr  
real*8, intent(in) :: rr, dtmin,Ah
real*8         :: uv(12),rg,localW !,en
real*4         :: qran(12),amp
integer, intent(in)        :: ia,ja,ka, ff, imt,jmt,km
integer :: im,jm,n
real(kind=8),   intent(in),     dimension(imt-1,jmt,km,2)         :: uflux
real(kind=8),   intent(in),     dimension(imt,jmt-1,km,2)         :: vflux
! #ifdef  full_wflux
!     ! Not sure if this is right
!     real(kind=8),        dimension(imt,jmt,km+1,2)         :: wflux
! #else
    real(kind=8),        dimension(0:km,2)         :: wflux
! #endif
integer                                         :: nsm=1,nsp=2

!amp=Ah/sqrt(dt)
!amp=Ah/dtmin
!amp=Ah/sqrt(dtmin)
amp=Ah/( dtmin**(1./3.) )
!print *,Ah,dt,amp
!stop 4967
!  call random_number(qran) ! generates a random number between 0 and 1
  
! random generated numbers between 0 and 1
!do n=1,12
 !qran(n)=rand()
 CALL RANDOM_NUMBER (qran)
!enddo
	
!  qran=2.*qran-1. ! === Max. amplitude of turbulence with random numbers between -1 and 1
                   ! === (varies with the same aplitude as the mean vel)
  !qran=1.*qran-0.5  ! Reduced amplitude of turb.
!  qran=4.*qran-2. ! ===  amplitude of turbulence with random numbers between -2 and 2
!  qran=8.*qran-4. ! ===  amplitude of turbulence with random numbers between -2 and 2 only works with !  upr(:,1)=upr(:,2)
!  qran=30.*qran-15. ! ===  amplitude of turbulence with random numbers between -2 and 2 only works with !  upr(:,1)=upr(:,2)
  qran=amp*qran-0.5*amp ! ===  amplitude of turbulence with random numbers between -2 and 2 only works with !  upr(:,1)=upr(:,2)
    
  rg=1.d0-rr
  
  im=ia-1
!   if(im.eq.0) im=IMT # KMT commented this. Isn't this a periodic condition?
  jm=ja-1
  
#if defined timestep
  ! time interpolated velocities
  uv(1)=(rg*uflux(ia,ja,ka,nsp)+rr*uflux(ia,ja,ka,nsm))*ff ! western u
  uv(2)=(rg*uflux(im,ja,ka,nsp)+rr*uflux(im,ja,ka,nsm))*ff ! eastern u
  uv(3)=(rg*vflux(ia,ja,ka,nsp)+rr*vflux(ia,ja,ka,nsm))*ff ! northern v
  uv(4)=(rg*vflux(ia,jm,ka,nsp)+rr*vflux(ia,jm,ka,nsm))*ff ! southern v
#endif  

!   upr(:,1)=upr(:,2) ! store u' from previous time iteration step (this makes it unstable!)
   
! multiply the time interpolated velocities by random numbers
   
! 4 different random velocities at the 4 walls
!   upr(:,2)=uv(:)*rand(:) 
! or same random velocities at the eastern and western as well as nothern and southern
  upr(1,2)=uv(1)*qran(1)
  upr(2,2)=uv(2)*qran(1)
  upr(3,2)=uv(3)*qran(3)
  upr(4,2)=uv(4)*qran(3)

!  upr(:,1)=upr(:,2) ! impose same velocities for t-1 and t (this makes it unstable! but why? K.D��s)
  
#ifdef turb 
#ifndef twodim   
  ! === Calculates the w' at the top of the box from 
  ! === the divergence of u' and v' in order
  ! === to respect the continuity equation even 
  ! === for the turbulent velocities
  do n=1,2
     
     !Detta ser ut som en bugg   ! t2
     !  upr(5,n) = w(ka-1) - ff * ( upr(1,n) - upr(2,n) + upr(3,n) - upr(4,n) )
     !  upr(6,n) = 0.d0
     !Detta g�r att man bara justerar vertikala hastigheten p� ovansidan av boxen ! u2
     !  upr(5,n) = - ff * ( upr(1,n) - upr(2,n) + upr(3,n) - upr(4,n) )
     !  upr(6,n) = 0.d0
     
     ! === The vertical velocity is calculated from 
     ! === the divergence of the horizontal turbulence !v2
     ! === The turbulent is evenly spread between the 
     ! === top and bottom of box if not a bottom box

! #ifdef full_wflux
!     localW=wflux(ia,ja,ka-1,nsm)
! #else
    localW=wflux(ka-1,nsm)
! #endif
    
    if(localW.eq.0.d0) then
       upr(5,n) = - ff * ( upr(1,n) - upr(2,n) + upr(3,n) - upr(4,n) )
       upr(6,n) = 0.d0
    else
       upr(5,n) = - 0.5d0 * ff * ( upr(1,n) - upr(2,n) + upr(3,n) - upr(4,n) )
       upr(6,n) = - upr(5,n)
    endif

 enddo
#endif
#endif
 
 
 return
#endif ! KMT had to move this inside subroutine
end subroutine turbuflux
!_______________________________________________________________________
