import styled from 'styled-components';

export const Container = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: calc(100vh - 80px - 96px); // Adjusted to actual height values
  padding: 20px;
  position: relative; /* Set the position to relative for absolute child positioning */
  box-sizing: border-box;
  overflow: hidden; /* Prevents video from overflowing */
`;

export const VideoBg = styled.video`
  width: 100%;
  height: 100%;
  -o-object-fit: cover;
  object-fit: cover;
  background: #232a34;
  position: absolute;
  top: 0;
  left: 0;
  z-index: 1; // Ensure it's behind the content

  &::after {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    background: linear-gradient(to bottom, rgba(255, 255, 255, 0.5), transparent);
    z-index: 2; // Ensure it's above the video but below the content
  }
`;

export const StyledTypography = styled.p` // Assuming you want to style a <p> tag
  position: relative; // To ensure it's above the video overlay
  z-index: 3; // Above the after pseudo-element
  font-weight: normal;
  font-size: 24px;
  margin: 20px 0;
  text-align: center;
  color: #333; // Adjust the color accordingly
  background-color: rgba(255, 255, 255, 0.6); /* Or any other color */
  padding: 10px; /* Or as needed */
  border-radius: 15px; /* Optional, for rounded corners */
  max-width: 725px; /* Adjust this to your preference */
  width: 100%; /* This will make it responsive */
`;

export const BoldText = styled.span`
  font-weight: bold;
`;

export const StyledButton = styled.button`
  position: relative; // To ensure it's above the video overlay
  z-index: 3; // Above the after pseudo-element
  margin-top: 20px;
  padding: 10px 30px;
  font-size: 18px; // Adjust the size accordingly
`;
