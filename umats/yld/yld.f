c-----------------------------------------------------------------------
      subroutine yld(iyld_law,yldp,yldc,nyldp,nyldc,stress,phi,dphi,
     $     d2phi,ntens)
c-----------------------------------------------------------------------
c***  Arguments
c     iyld_law  : choice of yield function
c     yldp      : state variables associated with yield function
c     yldc      : constants for yield function
c     nyldp     : Len of yldp
c     nyldc     : Len of yldc
c     phi       : yield surface
c     dphi      : 1st derivative of yield surface w.r.t. stress
c     d2phi     : 2nd derivative of yield surface w.r.t. stress
c-----------------------------------------------------------------------
      implicit none
      integer iyld_law,nyldp,nyldc,ntens
      dimension yldp(nyldp),yldc(nyldc),dphi(ntens),d2phi(ntens,ntens)
      real*8 yldp,yldc,phi,dphi,d2phi
c***  Local variables for better readibility
      dimension stress(ntens)
      real*8 stress
c-----------------------------------------------------------------------
cf2py intent(in) iyld_law,yldp,yldc,nyldp,nyldc,stress,ntens
cf2py intent(out) phi,dphi,d2phi
c***  Define phi,dphi,d2phi
      if (iyld_law.eq.0) then
         call vm_shell(    stress,phi,dphi,d2phi)
      elseif (iyld_law.eq.1) then
         call hill48_shell(stress,phi,dphi,d2phi,yldc)
      elseif (iyld_law.eq.2) then
         call yld2000_2d(stress,phi,dphi,d2phi,yldc)
      elseif (iyld_law.eq.3) then ! yld2000-2d + HAH
         call hah(2,stress,phi,dphi,d2phi,yldc,yldp,nyldc,nyldp,ntens)
      else
         write(*,*)'Unexpected iyld_law given'
         stop -1
      endif
      end subroutine yld
c-----------------------------------------------------------------------
      subroutine update_yldp(iyld_law,yldp_ns,nyldp,deeq)
c     Arguments
c     iyld_law : yield function choice
c     yldp_ns  : yield parameters stored for two separate steps
c     nyldp    : len of yield parameters for each separate step
c     deeq     : incremental equivalent plastic strain
c-----------------------------------------------------------------------
c     intent(in) iyld_law,yldp_ns,nyldp,deeq
c-----------------------------------------------------------------------
      implicit none
      integer iyld_law,nyldp
      dimension yldp_ns(0:1,nyldp)
      real*8 yldp_ns,deeq
c     Depending on the choice of yield function
c     different types (and number) of state varibles are required.
      if (iyld_law.eq.0) then
c        ! For isotropic hardening, deeq is the sole state variable
c        that defines the yield surface 'size'

c        Actually, this may be abundant for von Mises isotropic yield function
c        stress will be sufficient to determine the yield surface...
         yldp_ns(1,1) = deeq + yldp_ns(0,1)
      elseif (iyld_law.eq.1) then
c        generic Hill48
         yldp_ns(1,1) = deeq + yldp_ns(0,1)
      elseif (iyld_law.eq.2) then
c        generic yld2000-2d + isotropic hardening
         yldp_ns(1,1) = deeq + yldp_ns(0,1)
      elseif (iyld_law.eq.3) then
c        generic yld2000-2d + HAH
         call hah_update(0,yldp_ns,nyldp,deeq)
      else
         write(*,*)'Unexpected iyld_law given in update_yldp'
         stop -1
      endif
      return
      end subroutine update_yldp
c-----------------------------------------------------------------------
c     Von Mises
      include "/home/younguj/repo/abaqusPy/umats/yld/vm.f"
c     Hill48
      include "/home/younguj/repo/abaqusPy/umats/yld/hill48.f"
c     yld2000-2d
      include "/home/younguj/repo/abaqusPy/umats/yld/yld2000_2d.f"
c     hah update
      include "/home/younguj/repo/abaqusPy/umats/yld/hah/hah_update.f"
